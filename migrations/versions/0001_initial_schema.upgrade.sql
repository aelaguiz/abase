-- The initial abase schema. See SCHEMA_PLAN.md for the design.
-- Runs inside the migration's transaction. Every object is schema-qualified.

-- ---------------------------------------------------------------------------
-- Functions
-- ---------------------------------------------------------------------------

-- Records every row change in abase.revisions and signals it on abase_changes.
-- TG_ARGV[0] names the table's primary-key column.
CREATE FUNCTION abase.audit() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    old_row jsonb;
    new_row jsonb;
    changed_row_id text;
    revision_id bigint;
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        old_row := to_jsonb(OLD) - 'search';
    END IF;
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        new_row := to_jsonb(NEW) - 'search';
    END IF;
    changed_row_id := coalesce(new_row, old_row) ->> TG_ARGV[0];

    INSERT INTO abase.revisions (table_name, row_id, op, old_row, new_row, actor)
    VALUES (
        TG_TABLE_NAME,
        changed_row_id,
        TG_OP,
        old_row,
        new_row,
        coalesce(nullif(current_setting('abase.actor', true), ''), session_user)
    )
    RETURNING id INTO revision_id;

    PERFORM pg_notify(
        'abase_changes',
        json_build_object(
            'table', TG_TABLE_NAME, 'row_id', changed_row_id, 'op', TG_OP, 'revision_id', revision_id
        )::text
    );
    RETURN NULL;
END;
$$;

-- Guards every insert and update of an entry.
CREATE FUNCTION abase.check_entry() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    successor record;
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW.kind <> OLD.kind THEN
            RAISE EXCEPTION 'entry % is a %; an entry''s kind never changes', OLD.id, OLD.kind;
        END IF;
        NEW.updated_at := now();
        IF NEW.state IS DISTINCT FROM OLD.state THEN
            NEW.state_changed_at := now();
        END IF;
    END IF;

    -- A record is superseded only by a current record of the same kind and scope.
    -- Locking the successor stops two transactions from superseding each other.
    IF NEW.superseded_by_id IS NOT NULL
        AND (TG_OP = 'INSERT' OR NEW.superseded_by_id IS DISTINCT FROM OLD.superseded_by_id) THEN
        SELECT kind, user_id, company_id, project_id, state INTO successor
        FROM abase.entries WHERE id = NEW.superseded_by_id FOR SHARE;
        IF FOUND THEN
            IF successor.kind <> NEW.kind
                OR (successor.user_id, successor.company_id, successor.project_id)
                    IS DISTINCT FROM (NEW.user_id, NEW.company_id, NEW.project_id) THEN
                RAISE EXCEPTION 'entry % can only be superseded by a % with the same user, company and project',
                    NEW.id, NEW.kind;
            END IF;
            IF successor.state <> 'current' THEN
                RAISE EXCEPTION 'entry % can only be superseded by a current entry; entry % is %',
                    NEW.id, NEW.superseded_by_id, successor.state;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE FUNCTION abase.deletes_allowed() RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT coalesce(current_setting('abase.allow_delete', true), '') = 'on'
$$;

CREATE FUNCTION abase.block_entry_delete() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT abase.deletes_allowed() THEN
        RAISE EXCEPTION 'entry % cannot be deleted: retire or supersede it instead (for an admin correction, SET LOCAL abase.allow_delete = on)', OLD.id;
    END IF;
    RETURN OLD;
END;
$$;

-- For append-only tables. A delete still goes through when abase.allow_delete is on,
-- so an admin can remove something that should never have been written, such as a secret.
CREATE FUNCTION abase.block_append_only_change() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' AND abase.deletes_allowed() THEN
        RETURN OLD;
    END IF;
    RAISE EXCEPTION '% is append-only: add a new row instead', TG_TABLE_NAME;
END;
$$;

CREATE FUNCTION abase.freeze_forecast() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF (NEW.forecast_of, NEW.forecast, NEW.range_text, NEW.rested_on)
        IS DISTINCT FROM (OLD.forecast_of, OLD.forecast, OLD.range_text, OLD.rested_on) THEN
        RAISE EXCEPTION 'forecast % is never rewritten: record a new forecast instead', OLD.entry_id;
    END IF;
    RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- Scopes
-- ---------------------------------------------------------------------------

CREATE TABLE abase.users (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    handle text NOT NULL UNIQUE CHECK (handle ~ '^[a-z0-9][a-z0-9-]*$'),
    name text NOT NULL CHECK (btrim(name) <> ''),
    created_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE abase.users IS 'The people whose values, preferences and mistakes the agents work from. Amir first.';

CREATE TABLE abase.companies (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9][a-z0-9-]*$'),
    name text NOT NULL CHECK (btrim(name) <> ''),
    created_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE abase.companies IS 'Each company the agents work for, such as Poker Skill and Cratejoy.';

-- ---------------------------------------------------------------------------
-- Entries: every record of every kind
-- ---------------------------------------------------------------------------

CREATE TABLE abase.entries (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kind text NOT NULL,
    user_id bigint REFERENCES abase.users (id),
    company_id bigint REFERENCES abase.companies (id),
    project_id bigint,
    key text CHECK (btrim(key) <> ''),
    title text NOT NULL CHECK (btrim(title) <> ''),
    body text NOT NULL DEFAULT '',
    guidance text,
    state text NOT NULL DEFAULT 'current' CHECK (state IN ('current', 'superseded', 'retired')),
    superseded_by_id bigint REFERENCES abase.entries (id),
    state_reason text,
    state_changed_at timestamptz NOT NULL DEFAULT now(),
    authority text NOT NULL CHECK (authority IN ('ruled', 'proposed', 'observed')),
    quote text,
    quote_by text,
    quote_at timestamptz,
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> ''),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    search tsvector GENERATED ALWAYS AS (
        to_tsvector('english'::regconfig, title || ' ' || body || ' ' || coalesce(guidance, ''))
    ) STORED,

    CONSTRAINT entries_kind_known CHECK (kind IN (
        'value', 'preference', 'communication_preference', 'mistake',
        'vocabulary_term', 'metric', 'data_gotcha', 'system', 'strategic_goal',
        'roadmap_item', 'change', 'report', 'specialist', 'project',
        'north_star', 'plan', 'bug', 'experiment', 'forecast', 'research'
    )),
    CONSTRAINT entries_scope_matches_level CHECK (
        (kind IN ('value', 'preference', 'communication_preference', 'mistake')
            AND user_id IS NOT NULL AND company_id IS NULL AND project_id IS NULL)
        OR (kind IN ('vocabulary_term', 'metric', 'data_gotcha', 'system', 'strategic_goal',
                     'roadmap_item', 'change', 'report', 'specialist', 'project')
            AND company_id IS NOT NULL AND user_id IS NULL AND project_id IS NULL)
        OR (kind IN ('north_star', 'plan', 'bug', 'experiment', 'forecast', 'research')
            AND project_id IS NOT NULL AND company_id IS NOT NULL AND user_id IS NULL)
    ),
    CONSTRAINT entries_key_required CHECK (
        kind NOT IN ('vocabulary_term', 'metric', 'system', 'report', 'specialist', 'project')
        OR key IS NOT NULL
    ),
    CONSTRAINT entries_superseded_has_successor CHECK (
        (state = 'superseded') = (superseded_by_id IS NOT NULL)
    ),
    CONSTRAINT entries_not_superseded_by_itself CHECK (superseded_by_id <> id),
    -- Projects, systems and reports have child rows of their own, so they keep
    -- their identity: they are updated or retired, never superseded.
    CONSTRAINT entries_kind_can_be_superseded CHECK (
        state <> 'superseded' OR kind NOT IN ('project', 'system', 'report')
    ),
    CONSTRAINT entries_ruled_has_quote CHECK (
        authority <> 'ruled'
        OR (btrim(quote) <> '' AND btrim(quote_by) <> '' AND quote_at IS NOT NULL)
    ),
    CONSTRAINT entries_id_kind UNIQUE (id, kind),
    CONSTRAINT entries_id_company UNIQUE (id, company_id),

    -- One current record per kind, scope and key. Absent scope columns compare
    -- as 0 so NULLs can't slip past. Checked at commit, so one transaction can
    -- add the replacement and then mark the old record superseded.
    CONSTRAINT entries_one_current_per_key EXCLUDE USING btree (
        kind WITH =,
        (coalesce(user_id, 0)) WITH =,
        (coalesce(company_id, 0)) WITH =,
        (coalesce(project_id, 0)) WITH =,
        (lower(key)) WITH =
    ) WHERE (state = 'current' AND key IS NOT NULL) DEFERRABLE INITIALLY DEFERRED
);

COMMENT ON TABLE abase.entries IS
    'Every record of every kind. Columns all kinds share live here; a kind with its own fields adds a detail table keyed by entry_id.';
COMMENT ON COLUMN abase.entries.key IS 'The name agents look a record up by: metric key, term, system name, project slug, specialist name.';
COMMENT ON COLUMN abase.entries.body IS 'The kind''s main text: a metric''s definition, a term''s meaning, research findings, what happened in a mistake.';
COMMENT ON COLUMN abase.entries.guidance IS 'What an agent should do because of this record.';
COMMENT ON COLUMN abase.entries.state IS 'current: in force. superseded: replaced by superseded_by_id. retired: no longer applies.';
COMMENT ON COLUMN abase.entries.authority IS
    'ruled: Amir decided it, with his words in quote. proposed: suggested by an agent or person, not ruled by Amir. observed: found from evidence.';
COMMENT ON COLUMN abase.entries.recorded_by IS 'Who wrote the row: a person, or an agent and its session.';
COMMENT ON COLUMN abase.entries.updated_at IS 'When this entries row last changed. Changes to detail rows show in abase.revisions.';

CREATE INDEX entries_kind_state ON abase.entries (kind, state);
CREATE INDEX entries_user ON abase.entries (user_id) WHERE user_id IS NOT NULL;
CREATE INDEX entries_company ON abase.entries (company_id) WHERE company_id IS NOT NULL;
CREATE INDEX entries_project ON abase.entries (project_id) WHERE project_id IS NOT NULL;
CREATE INDEX entries_updated_at ON abase.entries (updated_at);
CREATE INDEX entries_search ON abase.entries USING gin (search);

CREATE TRIGGER entries_check BEFORE INSERT OR UPDATE ON abase.entries
    FOR EACH ROW EXECUTE FUNCTION abase.check_entry();
CREATE TRIGGER entries_block_delete BEFORE DELETE ON abase.entries
    FOR EACH ROW EXECUTE FUNCTION abase.block_entry_delete();

-- ---------------------------------------------------------------------------
-- Projects: a project is both a company-level record (its home) and the scope
-- of project-level records. projects.company_id must match the entry's, and
-- every project-level entry's company must match its project's.
-- ---------------------------------------------------------------------------

CREATE TABLE abase.projects (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'project' CHECK (kind = 'project'),
    company_id bigint NOT NULL,
    project_status text NOT NULL DEFAULT 'active'
        CHECK (project_status IN ('active', 'paused', 'done', 'dropped')),
    state_summary text,
    started_on date,
    owner text,
    steward text,
    CONSTRAINT projects_entry_kind FOREIGN KEY (entry_id, kind)
        REFERENCES abase.entries (id, kind) ON DELETE CASCADE,
    CONSTRAINT projects_entry_company FOREIGN KEY (entry_id, company_id)
        REFERENCES abase.entries (id, company_id) ON DELETE CASCADE,
    CONSTRAINT projects_entry_id_company UNIQUE (entry_id, company_id)
);
COMMENT ON TABLE abase.projects IS 'Project homes. The entry holds the name (title), slug (key) and why we are building it (body).';

ALTER TABLE abase.entries ADD CONSTRAINT entries_project_in_company
    FOREIGN KEY (project_id, company_id) REFERENCES abase.projects (entry_id, company_id);

CREATE TABLE abase.milestones (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL REFERENCES abase.projects (entry_id) ON DELETE CASCADE,
    position integer NOT NULL,
    title text NOT NULL CHECK (btrim(title) <> ''),
    target_on date,
    milestone_status text NOT NULL DEFAULT 'planned'
        CHECK (milestone_status IN ('planned', 'in_progress', 'done', 'dropped')),
    done_on date,
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> ''),
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX milestones_project ON abase.milestones (project_id, position);

CREATE TABLE abase.project_log (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint NOT NULL REFERENCES abase.projects (entry_id) ON DELETE CASCADE,
    at timestamptz NOT NULL DEFAULT now(),
    note text NOT NULL CHECK (btrim(note) <> ''),
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> '')
);
COMMENT ON TABLE abase.project_log IS 'Each project''s work log. Append-only.';
CREATE INDEX project_log_project ON abase.project_log (project_id, at);
CREATE TRIGGER project_log_append_only BEFORE UPDATE OR DELETE ON abase.project_log
    FOR EACH ROW EXECUTE FUNCTION abase.block_append_only_change();

-- ---------------------------------------------------------------------------
-- Detail tables. Each one's (entry_id, kind) must match an entry of that kind.
-- Values, preferences, communication preferences and systems have none.
-- ---------------------------------------------------------------------------

CREATE TABLE abase.mistakes (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'mistake' CHECK (kind = 'mistake'),
    occurred_at timestamptz,
    underlying_cause text,
    cause_kind text,
    found_by text,
    cost text,
    systematic_fix text,
    fix_status text NOT NULL DEFAULT 'open'
        CHECK (fix_status IN ('open', 'fix_untested', 'fix_held', 'recurred')),
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.vocabulary_terms (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'vocabulary_term' CHECK (kind = 'vocabulary_term'),
    say_instead text,
    words_not_to_use text[] NOT NULL DEFAULT '{}',
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.metrics (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'metric' CHECK (kind = 'metric'),
    unit text,
    users_counted text,
    days_and_clock text,
    complete_when text,
    source text,
    source_status text NOT NULL DEFAULT 'good' CHECK (source_status IN ('good', 'no_good_source')),
    source_issues text,
    query_sql text,
    query_checked_at timestamptz,
    reference_value text,
    reference_period text,
    not_to_be_confused_with text,
    reported_by text,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.data_gotchas (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'data_gotcha' CHECK (kind = 'data_gotcha'),
    starts_on date,
    ends_on date,
    symptoms text,
    gotcha_status text NOT NULL DEFAULT 'open'
        CHECK (gotcha_status IN ('open', 'resolved', 'disproven')),
    status_changed_on date,
    CHECK (ends_on >= starts_on),
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.access_routes (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    system_entry_id bigint NOT NULL,
    system_kind text NOT NULL DEFAULT 'system' CHECK (system_kind = 'system'),
    route text NOT NULL CHECK (btrim(route) <> ''),
    identity text,
    credential_location text,
    route_status text NOT NULL DEFAULT 'unknown'
        CHECK (route_status IN ('working', 'broken', 'unknown')),
    last_verified_at timestamptz,
    last_verified_by text,
    notes text,
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> ''),
    created_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (system_entry_id, system_kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);
COMMENT ON COLUMN abase.access_routes.credential_location IS 'Where the secret lives. Never the secret itself.';
CREATE INDEX access_routes_system ON abase.access_routes (system_entry_id);

CREATE TABLE abase.strategic_goals (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'strategic_goal' CHECK (kind = 'strategic_goal'),
    measured_by text,
    numbers_from text,
    target text,
    due_on date,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.roadmap_items (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'roadmap_item' CHECK (kind = 'roadmap_item'),
    company_id bigint NOT NULL,
    theme text NOT NULL CHECK (btrim(theme) <> ''),
    position integer,
    roadmap_status text NOT NULL DEFAULT 'planned'
        CHECK (roadmap_status IN ('planned', 'in_progress', 'shipped', 'dropped')),
    status_note text,
    status_checked_at timestamptz,
    project_id bigint,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE,
    FOREIGN KEY (entry_id, company_id) REFERENCES abase.entries (id, company_id) ON DELETE CASCADE,
    CONSTRAINT roadmap_items_project_in_company FOREIGN KEY (project_id, company_id)
        REFERENCES abase.projects (entry_id, company_id)
);
COMMENT ON TABLE abase.roadmap_items IS 'Amir''s items versus agent-proposed ones are told apart by entries.authority.';

CREATE TABLE abase.changes (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'change' CHECK (kind = 'change'),
    effective_at timestamptz NOT NULL,
    found_at timestamptz,
    is_business_event boolean NOT NULL DEFAULT false,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);
COMMENT ON TABLE abase.changes IS 'Kept minimal: what belongs in the change log is not settled yet.';

CREATE TABLE abase.reports (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'report' CHECK (kind = 'report'),
    producer text NOT NULL CHECK (btrim(producer) <> ''),
    cadence text NOT NULL CHECK (btrim(cadence) <> ''),
    audience text NOT NULL CHECK (btrim(audience) <> ''),
    format text,
    home_url text,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.report_editions (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_entry_id bigint NOT NULL REFERENCES abase.reports (entry_id) ON DELETE CASCADE,
    delivered_at timestamptz NOT NULL,
    url text,
    delivered_to text,
    what_came_back text,
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> ''),
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX report_editions_report ON abase.report_editions (report_entry_id, delivered_at);

CREATE TABLE abase.specialists (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'specialist' CHECK (kind = 'specialist'),
    purview text NOT NULL CHECK (btrim(purview) <> ''),
    kpis text,
    how_to_start text,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);
COMMENT ON TABLE abase.specialists IS 'Role-based specialist agents. The entry holds the role (title), name (key) and responsibilities (body).';

CREATE TABLE abase.north_stars (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'north_star' CHECK (kind = 'north_star'),
    measured_by text,
    target text,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.plans (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'plan' CHECK (kind = 'plan'),
    why text,
    evidence text,
    blast_radius text,
    success_criteria text,
    stop_lines text,
    plan_status text NOT NULL DEFAULT 'draft'
        CHECK (plan_status IN ('draft', 'approved', 'executing', 'executed', 'abandoned')),
    approved_at timestamptz,
    executed_at timestamptz,
    retro_what_happened text,
    retro_learned text,
    retro_next_time text,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.bugs (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'bug' CHECK (kind = 'bug'),
    github_issue_url text,
    observed_at timestamptz,
    cause text,
    cause_class text,
    repair text,
    would_have_caught text,
    bug_status text NOT NULL DEFAULT 'open'
        CHECK (bug_status IN ('open', 'fixed', 'verified', 'wont_fix')),
    fixed_at timestamptz,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.experiments (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'experiment' CHECK (kind = 'experiment'),
    feature_flag text,
    variants text,
    deciding_metric text,
    stop_rule text,
    decision_owner text,
    started_on date,
    decision_on date,
    experiment_status text NOT NULL DEFAULT 'planned'
        CHECK (experiment_status IN ('planned', 'running', 'stopped', 'decided')),
    outcome text,
    decided_on date,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

CREATE TABLE abase.forecasts (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'forecast' CHECK (kind = 'forecast'),
    forecast_of text NOT NULL CHECK (btrim(forecast_of) <> ''),
    forecast text NOT NULL CHECK (btrim(forecast) <> ''),
    range_text text,
    rested_on text,
    read_on date,
    outcome text,
    outcome_recorded_at timestamptz,
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);
CREATE TRIGGER forecasts_frozen BEFORE UPDATE ON abase.forecasts
    FOR EACH ROW EXECUTE FUNCTION abase.freeze_forecast();

CREATE TABLE abase.research (
    entry_id bigint PRIMARY KEY,
    kind text NOT NULL DEFAULT 'research' CHECK (kind = 'research'),
    confidence text CHECK (confidence IN ('high', 'medium', 'low')),
    FOREIGN KEY (entry_id, kind) REFERENCES abase.entries (id, kind) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- Cross-cutting
-- ---------------------------------------------------------------------------

CREATE TABLE abase.links (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entry_id bigint NOT NULL REFERENCES abase.entries (id) ON DELETE CASCADE,
    url text NOT NULL CHECK (btrim(url) <> ''),
    label text,
    link_kind text NOT NULL CHECK (link_kind IN (
        'evidence', 'source', 'document', 'issue', 'pull_request', 'sheet', 'deck', 'other'
    )),
    source_label text,
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> ''),
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX links_entry ON abase.links (entry_id);

CREATE TABLE abase.entry_relations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_entry_id bigint NOT NULL REFERENCES abase.entries (id) ON DELETE CASCADE,
    to_entry_id bigint NOT NULL REFERENCES abase.entries (id) ON DELETE CASCADE,
    relation text NOT NULL CHECK (relation IN ('affects', 'measured_by', 'about', 'recurrence_of', 'related')),
    recorded_by text NOT NULL CHECK (btrim(recorded_by) <> ''),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (from_entry_id, to_entry_id, relation),
    CHECK (from_entry_id <> to_entry_id)
);
CREATE INDEX entry_relations_to ON abase.entry_relations (to_entry_id);

CREATE TABLE abase.revisions (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name text NOT NULL,
    row_id text NOT NULL,
    op text NOT NULL CHECK (op IN ('INSERT', 'UPDATE', 'DELETE')),
    old_row jsonb,
    new_row jsonb,
    actor text NOT NULL,
    changed_at timestamptz NOT NULL DEFAULT now(),
    txid xid8 NOT NULL DEFAULT pg_current_xact_id()
);
COMMENT ON TABLE abase.revisions IS
    'Every row change in every other table, written by trigger. Append-only. Each change is also signalled on NOTIFY channel abase_changes; the signal reaches only listeners connected at the time, so this table is the record.';
CREATE INDEX revisions_row ON abase.revisions (table_name, row_id);
CREATE INDEX revisions_changed_at ON abase.revisions (changed_at);
CREATE TRIGGER revisions_append_only BEFORE UPDATE OR DELETE ON abase.revisions
    FOR EACH ROW EXECUTE FUNCTION abase.block_append_only_change();

-- ---------------------------------------------------------------------------
-- Audit every table except revisions
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    audited record;
BEGIN
    FOR audited IN
        SELECT * FROM (VALUES
            ('users', 'id'), ('companies', 'id'), ('entries', 'id'),
            ('projects', 'entry_id'), ('milestones', 'id'), ('project_log', 'id'),
            ('mistakes', 'entry_id'), ('vocabulary_terms', 'entry_id'), ('metrics', 'entry_id'),
            ('data_gotchas', 'entry_id'), ('access_routes', 'id'), ('strategic_goals', 'entry_id'),
            ('roadmap_items', 'entry_id'), ('changes', 'entry_id'), ('reports', 'entry_id'),
            ('report_editions', 'id'), ('specialists', 'entry_id'), ('north_stars', 'entry_id'),
            ('plans', 'entry_id'), ('bugs', 'entry_id'), ('experiments', 'entry_id'),
            ('forecasts', 'entry_id'), ('research', 'entry_id'), ('links', 'id'),
            ('entry_relations', 'id')
        ) AS t (table_name, pk_column)
    LOOP
        EXECUTE format(
            'CREATE TRIGGER %I AFTER INSERT OR UPDATE OR DELETE ON abase.%I '
            'FOR EACH ROW EXECUTE FUNCTION abase.audit(%L)',
            audited.table_name || '_audit', audited.table_name, audited.pk_column
        );
    END LOOP;
END;
$$;
