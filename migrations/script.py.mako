"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}
"""

from migrations.sql import run_sql_file

revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}


def upgrade() -> None:
    run_sql_file(__file__, "upgrade")


def downgrade() -> None:
    run_sql_file(__file__, "downgrade")
