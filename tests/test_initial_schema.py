"""Checks that the rules in SCHEMA_PLAN.md hold in the migrated database."""

import json

import psycopg
import pytest
from alembic import command
from psycopg import errors

from tests.conftest import alembic_config, plain_url


def test_upgrade_downgrade_and_upgrade_again(scratch_database):
    url = scratch_database()
    config = alembic_config(url)
    command.upgrade(config, "head")
    command.downgrade(config, "base")
    command.upgrade(config, "head")
    with psycopg.connect(plain_url(url)) as conn:
        tables = conn.execute(
            "SELECT count(*) FROM pg_tables WHERE schemaname = 'abase' AND tablename <> 'alembic_version'"
        ).fetchone()[0]
    assert tables == 26


def test_kind_at_the_wrong_level_is_refused(records):
    user_id = records.user()
    with pytest.raises(errors.CheckViolation, match="entries_scope_matches_level"):
        records.entry("metric", user_id=user_id, key="new_users")


def test_project_level_kind_needs_a_project(records):
    company_id = records.company()
    with pytest.raises(errors.CheckViolation, match="entries_scope_matches_level"):
        records.entry("bug", company_id=company_id)


def test_user_level_record_is_the_same_for_every_company(records):
    with pytest.raises(errors.CheckViolation, match="entries_scope_matches_level"):
        records.entry("preference", user_id=records.user(), company_id=records.company())


def test_ruled_record_needs_the_quote(records):
    user_id = records.user()
    with pytest.raises(errors.CheckViolation, match="entries_ruled_has_quote"):
        records.entry("value", user_id=user_id, authority="ruled")


def test_ruled_record_with_quote_is_accepted(records):
    records.entry(
        "value",
        user_id=records.user(),
        authority="ruled",
        quote="See the evidence yourself.",
        quote_by="Amir",
        quote_at="2026-10-26T09:00:00-05:00",
    )


def test_keyed_kinds_need_a_key(records):
    with pytest.raises(errors.CheckViolation, match="entries_key_required"):
        records.entry("metric", company_id=records.company())


def test_second_current_record_with_the_same_key_is_refused_at_commit(conn, records):
    company_id = records.company()
    records.entry("metric", company_id=company_id, key="new_users")
    records.entry("metric", company_id=company_id, key="New_Users")
    with pytest.raises(errors.ExclusionViolation, match="entries_one_current_per_key"):
        conn.commit()


def test_same_key_in_another_company_is_fine(conn, records):
    records.entry("metric", company_id=records.company("-a"), key="new_users")
    records.entry("metric", company_id=records.company("-b"), key="new_users")
    conn.commit()


def test_superseding_inside_one_transaction_works(conn, records):
    company_id = records.company()
    old_id = records.entry("vocabulary_term", company_id=company_id, key="Blueprint")
    conn.commit()

    new_id = records.entry("vocabulary_term", company_id=company_id, key="Blueprint", body="newer meaning")
    conn.execute(
        "UPDATE abase.entries SET state = 'superseded', superseded_by_id = %s, state_reason = 'reworded' WHERE id = %s",
        [new_id, old_id],
    )
    conn.commit()

    rows = conn.execute(
        "SELECT id, state FROM abase.entries WHERE id IN (%s, %s) ORDER BY id", [old_id, new_id]
    ).fetchall()
    assert rows == [(old_id, "superseded"), (new_id, "current")]


def test_superseded_needs_a_successor(conn, records):
    entry_id = records.entry("data_gotcha", company_id=records.company())
    with pytest.raises(errors.CheckViolation, match="entries_superseded_has_successor"):
        conn.execute("UPDATE abase.entries SET state = 'superseded' WHERE id = %s", [entry_id])


def test_successor_needs_superseded_state(conn, records):
    company_id = records.company()
    entry_id = records.entry("data_gotcha", company_id=company_id)
    other_id = records.entry("data_gotcha", company_id=company_id)
    with pytest.raises(errors.CheckViolation, match="entries_superseded_has_successor"):
        conn.execute("UPDATE abase.entries SET superseded_by_id = %s WHERE id = %s", [other_id, entry_id])


def test_superseded_only_by_the_same_kind(conn, records):
    company_id = records.company()
    term_id = records.entry("vocabulary_term", company_id=company_id, key="Blueprint")
    gotcha_id = records.entry("data_gotcha", company_id=company_id)
    with pytest.raises(errors.RaiseException, match="can only be superseded by a vocabulary_term"):
        conn.execute(
            "UPDATE abase.entries SET state = 'superseded', superseded_by_id = %s WHERE id = %s",
            [gotcha_id, term_id],
        )


def test_superseded_only_within_the_same_company(conn, records):
    old_id = records.entry("data_gotcha", company_id=records.company("-a"))
    new_id = records.entry("data_gotcha", company_id=records.company("-b"))
    with pytest.raises(errors.RaiseException, match="same user, company and project"):
        conn.execute(
            "UPDATE abase.entries SET state = 'superseded', superseded_by_id = %s WHERE id = %s",
            [new_id, old_id],
        )


def test_superseding_cannot_go_in_a_circle(conn, records):
    company_id = records.company()
    first_id = records.entry("data_gotcha", company_id=company_id)
    second_id = records.entry("data_gotcha", company_id=company_id)
    conn.execute(
        "UPDATE abase.entries SET state = 'superseded', superseded_by_id = %s WHERE id = %s",
        [second_id, first_id],
    )
    with pytest.raises(errors.RaiseException, match="can only be superseded by a current entry"):
        conn.execute(
            "UPDATE abase.entries SET state = 'superseded', superseded_by_id = %s WHERE id = %s",
            [first_id, second_id],
        )


def test_projects_are_retired_not_superseded(conn, records):
    company_id = records.company()
    old_id = records.project(company_id, slug="old")
    new_id = records.project(company_id, slug="new")
    with pytest.raises(errors.CheckViolation, match="entries_kind_can_be_superseded"):
        conn.execute(
            "UPDATE abase.entries SET state = 'superseded', superseded_by_id = %s WHERE id = %s",
            [new_id, old_id],
        )


def test_roadmap_item_project_must_be_in_its_company(records):
    project_id = records.project(records.company("-a"))
    company_id = records.company("-b")
    item_id = records.entry("roadmap_item", company_id=company_id)
    with pytest.raises(errors.ForeignKeyViolation, match="roadmap_items_project_in_company"):
        records.insert(
            "roadmap_items", returning="entry_id",
            entry_id=item_id, company_id=company_id, theme="Retention", project_id=project_id,
        )


def test_detail_row_must_match_its_entry_kind(records):
    company_id = records.company()
    project_id = records.project(company_id)
    bug_id = records.entry("bug", company_id=company_id, project_id=project_id)
    with pytest.raises(errors.ForeignKeyViolation):
        records.insert("metrics", returning="entry_id", entry_id=bug_id)


def test_kind_never_changes(conn, records):
    company_id = records.company()
    entry_id = records.entry("research", company_id=company_id, project_id=records.project(company_id))
    with pytest.raises(errors.RaiseException, match="kind never changes"):
        conn.execute("UPDATE abase.entries SET kind = 'bug' WHERE id = %s", [entry_id])


def test_project_record_must_be_in_its_projects_company(records):
    project_id = records.project(records.company("-a"))
    with pytest.raises(errors.ForeignKeyViolation, match="entries_project_in_company"):
        records.entry("plan", company_id=records.company("-b"), project_id=project_id)


def test_every_write_is_recorded_and_announced(database_url, conn, records):
    with psycopg.connect(plain_url(database_url), autocommit=True) as listener:
        listener.execute("LISTEN abase_changes")

        conn.execute("SET LOCAL abase.actor = 'test-agent'")
        company_id = records.company()
        entry_id = records.entry("system", company_id=company_id, key="GA4")
        conn.execute("UPDATE abase.entries SET body = 'Google Analytics' WHERE id = %s", [entry_id])
        conn.commit()

        notices = [json.loads(n.payload) for n in listener.notifies(timeout=5, stop_after=3)]

    assert ("entries", str(entry_id), "UPDATE") in [(n["table"], n["row_id"], n["op"]) for n in notices]
    revisions = conn.execute(
        "SELECT op, actor, old_row ->> 'body', new_row ->> 'body' FROM abase.revisions "
        "WHERE table_name = 'entries' AND row_id = %s ORDER BY id",
        [str(entry_id)],
    ).fetchall()
    assert revisions == [
        ("INSERT", "test-agent", None, ""),
        ("UPDATE", "test-agent", "", "Google Analytics"),
    ]


def test_entries_are_retired_not_deleted(conn, records):
    entry_id = records.entry("preference", user_id=records.user())
    with pytest.raises(errors.RaiseException, match="cannot be deleted"):
        conn.execute("DELETE FROM abase.entries WHERE id = %s", [entry_id])


def test_admin_delete_works_when_allowed(conn, records):
    entry_id = records.entry("preference", user_id=records.user())
    conn.execute("SET LOCAL abase.allow_delete = on")
    conn.execute("DELETE FROM abase.entries WHERE id = %s", [entry_id])


def test_forecast_is_never_rewritten(conn, records):
    company_id = records.company()
    entry_id = records.entry("forecast", company_id=company_id, project_id=records.project(company_id))
    records.insert("forecasts", returning="entry_id", entry_id=entry_id, forecast_of="trials", forecast="1,000")
    conn.execute("UPDATE abase.forecasts SET outcome = '900' WHERE entry_id = %s", [entry_id])
    with pytest.raises(errors.RaiseException, match="never rewritten"):
        conn.execute("UPDATE abase.forecasts SET forecast = '1,200' WHERE entry_id = %s", [entry_id])


def test_project_log_and_revisions_are_append_only(conn, records):
    project_id = records.project(records.company())
    log_id = records.insert("project_log", project_id=project_id, note="started", recorded_by="tests")
    conn.commit()

    with pytest.raises(errors.RaiseException, match="append-only"):
        conn.execute("UPDATE abase.project_log SET note = 'edited' WHERE id = %s", [log_id])
    conn.rollback()
    with pytest.raises(errors.RaiseException, match="append-only"):
        conn.execute(
            "UPDATE abase.revisions SET actor = 'someone else' WHERE table_name = 'project_log' AND row_id = %s",
            [str(log_id)],
        )
