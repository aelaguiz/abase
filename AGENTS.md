# abase

A shared knowledge base and coordination system for Amir's coding agents, across his companies and projects. `BACKGROUND.md` has the goal and his starting thoughts. `ELEMENTS.md` lists what the base holds and which parts Amir put in scope.

## Where things stand

Discovery is still going on. The one thing being built is the initial Postgres database (`SCHEMA_PLAN.md`), in Python with Alembic migrations. Build nothing beyond the database until Amir asks for it: no access layer, Sheets or Slack sync, data import or skills.

## Amir's notes

Amir drops notes into chat as they come to him: short, unordered, often half-formed.

- Capture every note he gives you without being asked. Add it to `NOTES.md` under today's date, in his words, tidied only enough to read cleanly. Record what he said, not your expansion of it; if you have a thought or question about a note, say it in chat.
- Then commit and push: `git add -A && git commit -m "Capture notes: <topic>" && git push`.
- Reply in one line saying what you captured.

## Database

- **Setup:** `uv sync`.
- **Which database:** `DATABASE_URL` and `TEST_ADMIN_DATABASE_URL` (see `.env.example`). For the test database on amir-server, load them with `set -a; . ~/workspace/secrets/abase-test-db.env; set +a`.
- **Migrate:** `uv run alembic upgrade head`.
- **Test:** `uv run pytest`. The tests create and drop their own scratch databases. Run them after any schema change; a change is done when they pass and `SCHEMA_PLAN.md` describes it.
- **Change the schema:** run `uv run alembic revision --rev-id <next number, e.g. 0002> -m "<what changes>"`. Write the change in the `.upgrade.sql` and `.downgrade.sql` files beside it, named like `0001_initial_schema.*.sql`. Never edit a migration that has already been applied: a fix is a new migration.
- **Work log:** add a line to `WORKLOG.md` for each step of database work.

This repo is public on GitHub. Write down where sensitive things live, never their contents: no credentials, connection strings, network addresses, customer data, or company numbers such as revenue or metrics.
