# Initial database schema: plan

How we set up the first version of the abase database: a Postgres schema built by Python migrations. It covers the elements Amir put in scope on 2026-10-26 (`ELEMENTS.md`, rows 1 to 20). It does not cover how agents or people reach the data, importing existing records, or syncing to Sheets or Slack.

## What this delivers

1. A Python project, managed with `uv`, that runs Alembic migrations against Postgres.
2. One initial migration that creates the whole schema below, inside its own Postgres schema, `abase`.
3. Tests that run the migration against a scratch database and check that the rules below hold.
4. A test database on the home server (`amir-server`), built by running the migration, and left running.

## Stack

- **Postgres 17.** Fly Managed Postgres offers 16 or 17. Nothing here needs more than Postgres 15, and no extensions are used.
- **Python 3.12 or newer.** Dependencies: `alembic`, `sqlalchemy` (Alembic needs it), `psycopg[binary]` 3, and `pytest`.
- **Hand-written SQL migrations.** Each migration runs plain SQL kept beside it. The schema leans on CHECK constraints, triggers and partial constraints that ORM autogeneration can't express, so there are no ORM models yet. Those come with the access layer.
- **Connection strings** come from `DATABASE_URL`, and never from the repo. The repo is public.

## Design rules

Each rule answers something that breaks in today's workspaces (`ELEMENTS.md`, "The comparison behind this list").

1. **One row per fact; no copies.** Where a record applies (to Amir, to a company or to a project) is a column, so the same rule is never copied into two places.
2. **History is kept, never rewritten.** Two cases:
   - An edit to a living record (a roadmap item's status, an access route's last check) is recorded in full in `revisions` by a trigger.
   - A record that is replaced (newer research, a changed preference) stays as it was and points to the record that replaced it.
3. **One answer to "is this still in force?"** Every record has `state`: `current`, `superseded` or `retired`. Kinds with a real workflow (a bug, a plan, an experiment) add their own status column with a fixed list of values.
4. **Authority is explicit on every record.** `authority` is one of:
   - `ruled`: Amir decided it, and his words are attached;
   - `proposed`: an agent or a person suggested it, and it stands until Amir rules;
   - `observed`: an agent found it from evidence.

   A `ruled` record must carry the quote, who said it and when.
5. **The database stamps time and order.** Ids and `created_at` come from Postgres, so many writers can't scramble the order.
6. **Every write is announced.** The same trigger that writes `revisions` sends a Postgres `NOTIFY` on channel `abase_changes`, so a watcher can see what changed without polling files.
7. **Rules live in the database, not in convention.** CHECKs, foreign keys and triggers apply to every client: Python, psql, a future Sheets sync.
8. **Records are retired, not deleted.** Deleting from `entries` is blocked unless a session explicitly turns that on for an admin correction.

## Tables

### Scopes

| Table | Columns | Notes |
|---|---|---|
| `users` | `id`, `handle` (unique), `name`, `created_at` | The top level. Amir first; teammates later |
| `companies` | `id`, `slug` (unique), `name`, `created_at` | Poker Skill, Cratejoy |

Projects are scopes too, but each project is also a record (its project home), so it lives in `entries` with a detail table (below).

### `entries`: every record of every kind

One row per record. The columns that every kind shares live here, and each kind adds a detail table only for the fields it alone has.

| Column | Type | Rule |
|---|---|---|
| `id` | bigint identity | Primary key |
| `kind` | text | One of the kinds listed below |
| `user_id` | bigint → `users` | Set for user-level kinds |
| `company_id` | bigint → `companies` | Set for company- and project-level kinds. A user-level record may also set it, to say it applies at one company only |
| `project_id` | bigint → `projects` | Set for project-level kinds. A composite foreign key (`project_id`, `company_id`) → `projects` (`entry_id`, `company_id`) guarantees the company matches the project's |
| `key` | text | The name agents look a record up by: metric key, term, system name, project slug, specialist name. Required for those kinds, optional for the rest |
| `title` | text, not blank | The record in one line |
| `body` | text | The kind's main text (per kind, below) |
| `guidance` | text | What an agent should do because of this record: how to apply a preference, how to handle a gotcha, how to think next time after a mistake |
| `state` | text | `current`, `superseded` or `retired` |
| `superseded_by_id` | bigint → `entries` | Set if and only if `state = 'superseded'`; never itself |
| `state_reason` | text | Why it was superseded or retired |
| `state_changed_at` | timestamptz | |
| `authority` | text | `ruled`, `proposed` or `observed` |
| `quote` | text | Verbatim words behind the record. Required when `ruled` |
| `quote_by` | text | Who said them. Required when `ruled` |
| `quote_at` | timestamptz | When. Required when `ruled` |
| `recorded_by` | text | Who wrote the row: a person, or an agent and its session. Free text until the per-agent design is settled |
| `created_at`, `updated_at` | timestamptz | Set by the database; `updated_at` by trigger |
| `search` | tsvector, generated | From title, body and guidance, with a GIN index |

**Kinds and the level each lives at**, enforced by a CHECK:

| Level | Kinds | Scope columns |
|---|---|---|
| User | `value`, `preference`, `communication_preference`, `mistake` | `user_id` required; `company_id` optional; `project_id` empty |
| Company | `vocabulary_term`, `metric`, `data_gotcha`, `system`, `strategic_goal`, `roadmap_item`, `change`, `report`, `specialist`, `project` | `company_id` required; `user_id` and `project_id` empty |
| Project | `north_star`, `plan`, `bug`, `experiment`, `forecast`, `research` | `project_id` and `company_id` required; `user_id` empty |

**One current record per key.** A deferred exclusion constraint allows only one `current` record with the same kind, scope and `lower(key)`. Because it is checked at commit, one transaction can insert the replacement and then mark the old record superseded.

### Detail tables, one per kind that needs them

Each detail table's primary key is `entry_id`. It also carries a constant `kind` column, and a composite foreign key (`entry_id`, `kind`) → `entries` (`id`, `kind`) guarantees the detail row belongs to an entry of the right kind.

| Kind | Element (`ELEMENTS.md` row) | `title` / `key` / `body` | Detail columns |
|---|---|---|---|
| `value` | Values (1) | the value / – / what it means | none |
| `preference` | Preferences (2) | the preference / – / the lesson | none |
| `communication_preference` | Communication preferences (3) | the preference / – / the detail | none |
| `mistake` | Mistakes (4) | short label / – / what happened | `mistakes`: `occurred_at`, `underlying_cause`, `cause_kind`, `found_by`, `cost`, `systematic_fix`, `fix_status` (`open`, `fix_untested`, `fix_held`, `recurred`) |
| `vocabulary_term` | Vocabulary (5) | the term / the term / what it means | `vocabulary_terms`: `say_instead`, `words_not_to_use` (text[]) |
| `metric` | Metric catalog (6) | metric name / metric key / definition | `metrics`: `unit`, `users_counted`, `days_and_clock`, `complete_when`, `source`, `source_status` (`good`, `no_good_source`), `source_issues`, `query_sql`, `query_checked_at`, `reference_value`, `reference_period`, `not_to_be_confused_with`, `reported_by` |
| `data_gotcha` | Data gotchas (7) | the trap / – / what happened | `data_gotchas`: `starts_on`, `ends_on`, `symptoms`, `gotcha_status` (`open`, `resolved`, `disproven`), `status_changed_on` |
| `system` | Systems and access (8) | system name / system name / what it is | child table `access_routes` (below) |
| `strategic_goal` | Strategic goals (9) | the goal / – / context | `strategic_goals`: `measured_by`, `numbers_from`, `target`, `due_on` |
| `roadmap_item` | Roadmap (10) | item / – / what it is | `roadmap_items`: `theme` (Amir's grouping), `position`, `roadmap_status` (`planned`, `in_progress`, `shipped`, `dropped`), `status_note`, `status_checked_at`, `project_id` (optional). Amir's items versus agent-proposed ones are told apart by `authority` |
| `change` | Change log and business events (11) | what changed / – / detail | `changes`: `effective_at`, `found_at`, `area`, `change_type`, `is_business_event`, `event_category`, `verified_how`. Provisional: Amir has yet to settle what belongs here |
| `report` | Reports (12) | report name / report name / what it answers | `reports`: `producer`, `cadence`, `audience`, `format`, `home_url`; child table `report_editions` (below) |
| `specialist` | Specialists (20) | role / specialist name / responsibilities | `specialists`: `purview`, `kpis`, `how_to_start` |
| `project` | Project home (13) | project name / slug / why we're building it | `projects`: `company_id`, `project_status` (`active`, `paused`, `done`, `dropped`), `state_summary`, `started_on`, `owner`, `steward`; child tables `milestones` and `project_log` (below) |
| `north_star` | North star goals (14) | the goal / – / context | `north_stars`: `measured_by`, `target` |
| `plan` | Plans (15) | plan name / – / the proposed change | `plans`: `why`, `evidence`, `blast_radius`, `success_criteria`, `stop_lines`, `plan_status` (`draft`, `approved`, `executing`, `executed`, `abandoned`), `approved_at`, `executed_at`, `retro_what_happened`, `retro_learned`, `retro_next_time` |
| `bug` | Bugs and regressions (16) | the symptom / – / what was observed | `bugs`: `github_issue_url`, `observed_at`, `cause`, `cause_class`, `repair`, `would_have_caught`, `bug_status` (`open`, `fixed`, `verified`, `wont_fix`), `fixed_at` |
| `experiment` | Experiments (17) | experiment name / – / the question it answers | `experiments`: `feature_flag`, `variants`, `deciding_metric`, `stop_rule`, `decision_owner`, `started_on`, `decision_on`, `experiment_status` (`planned`, `running`, `stopped`, `decided`), `outcome`, `decided_on` |
| `forecast` | Forecasts (18) | what is forecast / – / reasoning | `forecasts`: `forecast_of`, `forecast`, `range_text`, `rested_on`, `read_on`, `outcome`, `outcome_recorded_at`. A trigger blocks changing the forecast itself after insert; a new forecast is a new row |
| `research` | Research (19) | the question / – / findings | `research`: `confidence` (`high`, `medium`, `low`, optional). Sources go in `links` |

### Child tables

| Table | Columns | Notes |
|---|---|---|
| `access_routes` | `id`, `system_entry_id`, `route`, `identity`, `credential_location`, `route_status` (`working`, `broken`, `unknown`), `last_verified_at`, `last_verified_by`, `notes`, `recorded_by`, `created_at` | One system has several routes. `credential_location` says where the secret lives, never the secret |
| `report_editions` | `id`, `report_entry_id`, `delivered_at`, `url`, `delivered_to`, `what_came_back`, `recorded_by` | Answers "when did it last run" and "what came back" |
| `milestones` | `id`, `project_id`, `position`, `title`, `target_on`, `milestone_status` (`planned`, `in_progress`, `done`, `dropped`), `done_on` | |
| `project_log` | `id`, `project_id`, `at`, `note`, `recorded_by` | The project's work log. Append-only (a trigger blocks update and delete) |

### Cross-cutting tables

| Table | Columns | Notes |
|---|---|---|
| `links` | `id`, `entry_id`, `url`, `label`, `link_kind` (`evidence`, `source`, `document`, `issue`, `pull_request`, `sheet`, `deck`, `other`), `source_label`, `recorded_by`, `created_at` | Evidence, sources and the linked documents of a project home |
| `entry_relations` | `from_entry_id`, `to_entry_id`, `relation` (`affects`, `measured_by`, `about`, `recurrence_of`, `related`), `recorded_by`, `created_at` | For example, a gotcha `affects` a metric, or a north star is `measured_by` a metric |
| `revisions` | `id`, `table_name`, `row_id`, `op`, `old_row` (jsonb), `new_row` (jsonb), `actor`, `changed_at`, `txid` | Written by trigger on every insert, update and delete in every other table. `actor` comes from the session setting `abase.actor`, falling back to the database user |

## Triggers and functions

- `abase.audit()`: after every row change in every table except `revisions`, writes a `revisions` row and sends `NOTIFY abase_changes` with `{table, row_id, op}`.
- `abase.touch_updated_at()`: keeps `entries.updated_at` current.
- `abase.block_entry_delete()`: refuses `DELETE` on `entries` unless `abase.allow_delete` is `on` for the session.
- `abase.block_append_only_change()`: refuses update and delete on `project_log`.
- `abase.freeze_forecast()`: refuses changes to `forecast_of`, `forecast`, `range_text` and `rested_on` after insert.

## Migrations

- **Layout:** `migrations/` (Alembic `env.py` and `versions/`), with each version's SQL in a matching `.sql` file that the version runs.
- **Version table:** `env.py` creates the `abase` schema if it is missing, and keeps Alembic's version table there, so the database can share a Fly cluster with other apps.
- **One change per migration.** An applied migration is never edited; a fix is a new migration.
- **Downgrade:** the initial migration's downgrade drops everything it created. Later migrations each undo their own change.
- **Commands:**
  - `uv run alembic upgrade head` applies migrations.
  - `uv run alembic downgrade -1` steps back one.
  - `uv run pytest` runs the tests.

## Tests

The tests run against a scratch database that they create and drop on the test server. They need `TEST_ADMIN_DATABASE_URL`, a connection that is allowed to create databases. They check that:

1. upgrade to head, downgrade to base and upgrade again all succeed;
2. a record at the wrong level for its kind is refused;
3. a `ruled` record without a quote is refused;
4. a second `current` record with the same kind, scope and key is refused, but superseding inside one transaction works;
5. `superseded` without `superseded_by_id`, and the reverse, are refused;
6. a detail row pointing at an entry of another kind is refused;
7. every insert, update and delete writes a `revisions` row, and a listener receives the `NOTIFY`;
8. deleting an entry is refused unless `abase.allow_delete` is on;
9. a project-level record whose `company_id` differs from its project's is refused;
10. changing a forecast after insert is refused, and `project_log` rows can't be changed.

## Test database

- **Where:** the home server, `amir-server`. It runs Linux, is idle, has 114 GB of memory free and has Docker. Its own Postgres 16 on `127.0.0.1:5432` belongs to something else and is left alone.
- **What:** a Docker container `abase-postgres` running `postgres:17`, with a named volume and restart `unless-stopped`. It listens only on the server's Tailscale address, port 5442, so machines on the tailnet can reach it and nothing else can.
- **Password:** generated once and kept on this Mac in `~/workspace/secrets/`, never in the repo.
- **Build:** run `uv run alembic upgrade head` from this Mac over Tailscale, then run the tests.

## Open questions

These need Amir's answer before this initial migration is done:

1. **The change log.** What belongs in it, versus the project work log and GitHub. The `changes` table is provisional until he decides.
2. **User-level records at one company.** Whether a user-level record (a preference or a mistake) may name a single company it applies to. The plan allows it.
3. **Who wrote a record.** `recorded_by` and `actor` stay free text until Amir settles the per-agent architecture.

These are later steps, not part of this migration:

4. **Database roles and grants on Fly.** For example, a read-only role for people, and an app role without delete rights.
5. **Search.** Searching detail columns, and meaning-based search with pgvector.
