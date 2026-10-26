import os
import uuid
from pathlib import Path

import psycopg
import pytest
from alembic import command
from alembic.config import Config
from psycopg import sql

ROOT = Path(__file__).resolve().parent.parent


def plain_url(url: str) -> str:
    """psycopg wants postgresql://, Alembic's SQLAlchemy URL says postgresql+psycopg://."""
    return url.replace("postgresql+psycopg://", "postgresql://", 1)


def alembic_config(database_url: str) -> Config:
    config = Config(str(ROOT / "alembic.ini"))
    config.attributes["database_url"] = database_url
    return config


@pytest.fixture(scope="session")
def admin_url() -> str:
    url = os.environ.get("TEST_ADMIN_DATABASE_URL")
    if not url:
        pytest.fail("Set TEST_ADMIN_DATABASE_URL to a connection that may create databases.")
    return url


@pytest.fixture(scope="session")
def scratch_database(admin_url):
    """Makes empty databases on the test server and drops them when the session ends."""
    created = []

    def make() -> str:
        name = f"abase_test_{uuid.uuid4().hex[:12]}"
        with psycopg.connect(plain_url(admin_url), autocommit=True) as conn:
            conn.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(name)))
        created.append(name)
        return admin_url.rsplit("/", 1)[0] + "/" + name

    yield make

    with psycopg.connect(plain_url(admin_url), autocommit=True) as conn:
        for name in created:
            conn.execute(sql.SQL("DROP DATABASE IF EXISTS {} WITH (FORCE)").format(sql.Identifier(name)))


@pytest.fixture(scope="session")
def database_url(scratch_database) -> str:
    url = scratch_database()
    command.upgrade(alembic_config(url), "head")
    return url


@pytest.fixture
def conn(database_url):
    with psycopg.connect(plain_url(database_url)) as connection:
        yield connection
        connection.rollback()


class Records:
    """Adds rows for one test, under names no other test uses."""

    def __init__(self, conn):
        self.conn = conn
        self.tag = uuid.uuid4().hex[:8]

    def insert(self, table: str, returning: str = "id", **values):
        query = sql.SQL("INSERT INTO abase.{} ({}) VALUES ({}) RETURNING {}").format(
            sql.Identifier(table),
            sql.SQL(", ").join(map(sql.Identifier, values)),
            sql.SQL(", ").join(sql.Placeholder() * len(values)),
            sql.Identifier(returning),
        )
        return self.conn.execute(query, list(values.values())).fetchone()[0]

    def user(self) -> int:
        return self.insert("users", handle=f"user-{self.tag}", name="Test user")

    def company(self, suffix: str = "") -> int:
        return self.insert("companies", slug=f"company-{self.tag}{suffix}", name="Test company")

    def entry(self, kind: str, **values) -> int:
        values = {"title": f"{kind} {self.tag}", "authority": "observed", "recorded_by": "tests", **values}
        return self.insert("entries", kind=kind, **values)

    def project(self, company_id: int, slug: str = "project") -> int:
        entry_id = self.entry("project", company_id=company_id, key=f"{slug}-{self.tag}")
        self.insert("projects", returning="entry_id", entry_id=entry_id, company_id=company_id)
        return entry_id


@pytest.fixture
def records(conn) -> Records:
    return Records(conn)
