# Work log

What agents did in this repo, newest at the bottom. Times are US Central.

## 2026-10-26: initial database schema

Amir's ask: plan the initial Postgres schema (Python, migrations), get one round of review from GPT-6 Astra at xhigh, stand the database up on a test machine via the migrations, then stop.

- 07:26 Started. Saved Amir's notes on Postgres, Python and migrations to NOTES.md.
- 07:29 Wrote SCHEMA_PLAN.md and pushed it. Picked amir-server for the test database (idle Linux box with Docker; the Mac Studio is under heavy load). Sent the plan to GPT-6 Astra at xhigh for one review round (receipts in /private/tmp/claude-501/-Users-aelaguiz-workspace-abase/418ec1db-ca54-4ffa-9a33-181e54405d0c/scratchpad/fresh-consult-schema-plan-20261026T122940Z-C6tDRg).
- 07:30 Started the test database on amir-server: Docker container `abase-postgres` (postgres:17, which is 17.11), volume `abase-pgdata`, restart unless-stopped, listening only on the server's Tailscale address, port 5442. Password generated into ~/workspace/secrets/abase-test-db.env on Amir's Mac, not in the repo. Confirmed this Mac can connect.
- 07:31 Scaffolded the Python project: uv with alembic, sqlalchemy, psycopg 3 and pytest; Alembic config whose env.py reads DATABASE_URL and keeps its version table in the `abase` schema; each migration runs plain SQL files kept beside it.
- 07:33 Wrote migration 0001 (upgrade and downgrade SQL) from the plan. A trial run on a throwaway database built 26 tables and 30 triggers and downgraded cleanly.
- 07:34 Wrote tests for every rule in the plan (20 tests). All pass against scratch databases on the test server, and the scratch databases are dropped afterwards.
- 07:38 Astra's review came back: verdict fail. It keeps the architecture and stack and asks for: frozen research and forecasts; a pending state so an agent's proposal can sit beside Amir's ruling on the same key; supersession limited to the same kind and scope, with no cycles; reader and writer roles now; required detail rows; company checks on roadmap items; notification and ordering wording; more tests; container hardening. Some points were already covered by the SQL written meanwhile (composite-key targets, NULL-safe uniqueness, the migration transaction boundary, driver URLs). Applying the rest.
- 07:42 Amir: don't let Astra drive scope. Kept only the fixes for holes in what the plan already promised: supersession limited to a current record of the same kind and scope; projects, systems and reports can't be superseded; user-level records apply to every company; the company check on roadmap items; a minimal change log; the revision id in each change signal; honest wording on signals and ordering. Dropped the rest: roles and grants, pending proposals, research freezing, required detail rows, rolled-up updated_at, container hardening. Updated SCHEMA_PLAN.md to match, with a Review section saying what was taken and what was declined. 25 tests pass.
- 07:42 Built the test database: ran `alembic upgrade head` against the `abase` database on amir-server. Checked from a new connection: 26 tables, version 0001, empty. Stopped here, as Amir asked.
