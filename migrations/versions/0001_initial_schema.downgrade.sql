-- Undoes 0001_initial_schema: drops every table and function it created.
-- Leaves the abase schema itself, which holds Alembic's version table.

DROP TABLE IF EXISTS
    abase.revisions,
    abase.entry_relations,
    abase.links,
    abase.research,
    abase.forecasts,
    abase.experiments,
    abase.bugs,
    abase.plans,
    abase.north_stars,
    abase.specialists,
    abase.report_editions,
    abase.reports,
    abase.changes,
    abase.roadmap_items,
    abase.strategic_goals,
    abase.access_routes,
    abase.data_gotchas,
    abase.metrics,
    abase.vocabulary_terms,
    abase.mistakes,
    abase.project_log,
    abase.milestones,
    abase.projects,
    abase.entries,
    abase.companies,
    abase.users
CASCADE;

DROP FUNCTION IF EXISTS
    abase.audit(),
    abase.check_entry(),
    abase.block_entry_delete(),
    abase.block_append_only_change(),
    abase.freeze_forecast(),
    abase.deletes_allowed();
