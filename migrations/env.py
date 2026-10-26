import os

from alembic import context
from sqlalchemy import create_engine, pool, text

SCHEMA = "abase"


def database_url() -> str:
    url = context.config.attributes.get("database_url") or os.environ.get("DATABASE_URL")
    if not url:
        raise RuntimeError("Set DATABASE_URL to the database to migrate.")
    for prefix in ("postgres://", "postgresql://"):
        if url.startswith(prefix):
            return "postgresql+psycopg://" + url[len(prefix):]
    return url


def run_migrations() -> None:
    engine = create_engine(database_url(), poolclass=pool.NullPool)
    with engine.connect() as connection:
        connection.execute(text(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA}"))
        connection.commit()
        context.configure(
            connection=connection,
            version_table_schema=SCHEMA,
            transaction_per_migration=True,
        )
        with context.begin_transaction():
            context.run_migrations()
    engine.dispose()


if context.is_offline_mode():
    raise RuntimeError("Offline SQL generation is not supported; run against a database.")
run_migrations()
