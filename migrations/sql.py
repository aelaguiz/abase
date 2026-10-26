"""Runs the SQL file that sits beside a migration.

Each migration `versions/<rev>_<slug>.py` has `versions/<rev>_<slug>.upgrade.sql`
and `versions/<rev>_<slug>.downgrade.sql`. The SQL goes to psycopg with no
parameters, so a file may hold many statements and dollar-quoted function bodies.
"""

from pathlib import Path

from alembic import op


def run_sql_file(migration_file: str, direction: str) -> None:
    path = Path(migration_file).with_suffix(f".{direction}.sql")
    sql = path.read_text()
    dbapi_connection = op.get_bind().connection.dbapi_connection
    with dbapi_connection.cursor() as cursor:
        cursor.execute(sql)
