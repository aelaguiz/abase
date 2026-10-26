"""Initial schema: scopes, entries, a detail table per kind, links, relations and revisions.

Revision ID: 0001
Revises:
Create Date: 2026-10-26
"""

from migrations.sql import run_sql_file

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    run_sql_file(__file__, "upgrade")


def downgrade() -> None:
    run_sql_file(__file__, "downgrade")
