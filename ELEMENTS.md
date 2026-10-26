# Common elements across the agent workspaces

What Amir's three agent workspaces already keep, compared on 2026-10-26, as the starting list for the data design.

- **PS Brain** (`~/workspace/psbrain`): Poker Skill's Chief and its agents and specialists. It owns decisions, planning and company memory.
- **PS Agent Space** (`~/workspace/psagentspace`): Poker Skill's execution workspace. It owns data access, delivery and scripts, and in practice most of the big ledgers.
- **Agent Space** (`~/workspace/agentspace`): Cratejoy's Chief and four specialists. Its structure was copied by hand from PS Brain's.

## What the comparison shows

1. **All three keep the same kinds of record.** These are vocabulary, a metric catalog, an access map, data gotchas, runbooks, intake of Amir's words, a task queue, project homes, plans, lessons from his corrections, mistakes, learnings, research, change logs and reports. Agent Space matches PS Brain closely because it was cloned from it. That means the common structure already exists, but as copies that drift.
2. **Five things exist in none of them:**
   - a single decision log;
   - a record of what each agent is working on right now;
   - a registry of reports (what exists, who produces it, how often, when it last ran);
   - a maintained list of people and who owns what;
   - a "superseded by" field.
3. **The same things break in all three:**
   - one-file ledgers grow too big to read;
   - "newest first" falls apart when many sessions append;
   - indexes drift from the folders they index;
   - copies of the same fact disagree;
   - every file has its own status words.

## Overview

| Element | PS Brain | PS Agent Space | Agent Space (Cratejoy) |
|---|---|---|---|
| Vocabulary | `$word-list` skill (the home for names) | Links to PS Brain's skill, but restates some definitions | No glossary; a short section in CLAUDE.md plus scattered lessons |
| Metric catalog | `$canonical-data` skill, 1,345 metrics | Model registry and metric rulings; defers to the warehouse canon | `$canonical-data` skill, 467 metrics, same shape |
| Data gotchas | Traps sections inside runbooks | `GOTCHAS.md`, about 457 entries | `docs/DATA-GOTCHAS.md`, about 81 entries |
| Systems and access | `knowledge/system-access.md` | `access/README.md` (the two overlap) | `docs/SYSTEM-ACCESS.md` |
| Company context and goals | `shared/company-context.md`, `shared/strategy/goals.md` | `roadmaps/company/` | Dated business snapshots in `docs/` |
| Amir's values | `shared/amir-values.md` | None | Hand copy of PS Brain's |
| People | One dossier in `relationships/` | Six team dossiers, last updated Sept 6 | None; an ownership tab in a team sheet |
| Runbooks | `knowledge/`, about 75 | `docs/` doctrine | `docs/*RUNBOOK.md` and doc packs |
| Intake (Amir's words) | `intake/`, 320 files | `GROWTH_IDEAS.md`, raw dictation files | `intake/`, 55 files |
| Decisions | `agents/news.md`, approval cards, one project register | Inline rulings in AGENTS.md and docs | "Decisions recorded" in each project home |
| Task queue | `operations/tasks.md`, C-### | GitHub issues and `plans/README.md` | `operations/tasks.md`, CJ-### |
| Projects | `projects/`, 78 homes | `roadmaps/` packs and topic folders | `projects/`, 34 homes |
| Roadmap | `shared/product-roadmap.md` | `roadmaps/` plus a status tab in the Growth Playbook sheet | Google Sheets only |
| Plans | Per-project `PLAN.md` | `plans/` drafts → executed → retros | `plans/` drafts → executed → retros |
| Bugs and regressions | Per-agent `breaks.md`, bug-filing corrections | `REGRESSIONS.md`, `docs/bugs/` | Sentry sweeps; GitHub issues |
| Experiments and forecasts | `agents/experiments/tests.md`, forecasts ledger | None | None |
| Lessons from corrections | `shared/feedback.md`, per-agent `corrections.md`, Claude memory | Folded into doctrine | `shared/feedback.md`, Claude memory |
| Mistakes | `shared/mistakes-retro.md` | Puzzle construction ledger, `docs/UNSAFE_COMMANDS.md` | Plan retros |
| Agent learnings | `learnings.md` per agent and specialist | Almost none | `learnings.md` per specialist |
| Research | `resources/`, specialists' `research/` | `research/`, 328 dated packs | Specialists' and projects' `research/` |
| Change log | `changes.md` per agent; CFO change ledger | `LOG.md`, `EVENTS.md` | `docs/worklogs/SITE-CHANGELOG.md` |
| Document and link index | `resources/workspace-documents.md`, W### | `SHARES.md` | Links in project homes |
| Reports | Per-agent `reports/<date>/`, `updates.md`, schedules | Monday update, report skills | Morning report planned, not built |
| Who is on what | Watcher session files (stale) | GitHub claim label, run logs | Nothing |
| Human views (Sheets) | Metric catalog, roadmap, ledgers | Growth Playbook, sheet-writer registry | Metric catalog, release tracker, team sheets |

## The elements

Each element below says what it holds, where it lives today, the shape it has settled into, and what goes wrong with it. The groups follow the five capabilities in `BACKGROUND.md`.

### Shared understanding

**1. Vocabulary.** What we call each thing, what it means, and the words not to use.
- **Today:** PS Brain's `$word-list` skill is the strongest version. Its columns are: what agents write, say instead, what it means, and status. Each name is marked **Ruled** (with the date Amir ruled) or **Proposed**. PS Agent Space links to that skill and says nothing in the repo may restate a name. Agent Space has no word list; its terms sit in a CLAUDE.md section, in lessons and in Claude memory.
- **What goes wrong:**
  - PS Agent Space restates event definitions anyway, and they now disagree: AGENTS.md says `InitiateCheckout` means checkout started, while `docs/CONTENT_AND_REPORTS.md` still gives the older meaning.
  - In PS Brain, the skill says its files are rebuilt from a project folder, but recent rulings were written straight into them, so the next rebuild would lose them.

**2. Metric catalog.** One way to count each number, and how to get it.
- **Today:** the same `$canonical-data` skill in PS Brain and Agent Space, with the same columns: definition, unit, users counted, days and clock, when it is complete, source, where the source stands, issues, query, reference value, and what it is not to be confused with. Each also has tested queries, a "no good source" list of metrics that have no reliable source yet (with the fix and its issue), a dated changes log, and a Google Sheet view titled "one way to count each". Both declare the skill the winner over any other file that counts a number differently.
- **What goes wrong:**
  - Dated business snapshots still quote figures the catalog has since corrected.
  - PS Brain's reference files have not been rebuilt since October 16.

**3. Data gotchas.** Traps in a source that make a number misleading, with how to handle them.
- **Today:** Agent Space's entry has a date range, the metrics affected, what happened, the symptoms, how to handle it, evidence, and a status of Open, Resolved or Disproven. PS Agent Space's `GOTCHAS.md` is written as "the trap / what it broke / the rule", and it mixes data traps with tool traps.
- **What goes wrong:** both are single files read only in slices. "Newest first" no longer holds in either.

**4. Systems and access.** Every system, the route that works, where the credential lives, and when the route last worked.
- **Today:** all three have one, with the same row shape: system, route, identity or credential location, status, and date verified. Each Agent Space specialist has a skill that re-checks its routes.
- **What goes wrong:** Poker Skill has two maps, PS Brain's and PS Agent Space's, and each points at the other.

**5. Company context, strategy and goals.** What each company is trying to do and how success is measured.
- **Today:** PS Brain's `goals.md` gives each goal in Amir's words, the date he set it, how it is measured and where the numbers come from. The rest are dated snapshots: company context, capabilities, and Agent Space's August business state.
- **What goes wrong:** the snapshots are not refreshed, and agents are told that "dated documents are historical evidence, not current state."

**6. Amir's values.** What he cares about, in his words, and how agents act on it.
- **Today:** a table in PS Brain, copied by hand into Agent Space, with a note to "update both when Amir changes one."

**7. People.** Who is on the team, their role, what they own, and their Slack and GitHub handles.
- **Today:** six dossiers in PS Agent Space (last updated September 6), one in PS Brain, none in Agent Space. Ownership otherwise lives in a sheet tab.
- **What goes wrong:** the changelog records one person under several spellings.

**8. Runbooks.** How to do a recurring, multi-step job.
- **Today:** all three have them, with the same sections: when to use it, owner, before you start, steps, traps, checks, and last verified. All three have the same rule: write or update the runbook the same day you first finish the job or hit a new trap.

### Shared state

**9. Intake: Amir's words.** Every substantive input from Amir, captured before anyone acts on it.
- **Today:** PS Brain and Agent Space use the same entry, one file per input:
  - date, and where it came from (session, Slack, voice);
  - his words, verbatim;
  - what kind of words they were: his decision, his instruction, a request, or a passing thought;
  - the agent's reading, kept separate;
  - where it was routed, and status.

  PS Agent Space has an ideas inbox with statuses `raw`, `exploring`, `planned`, `shipped` and `dropped`.
- **What goes wrong:**
  - Intake indexes fall behind: 17 of Agent Space's 53 files are missing from its index.
  - Routes point at folders that were renamed.

**10. Decisions.** What Amir decided, in his words, and what it replaces.
- **Today:** spread across every workspace:
  - PS Brain's `agents/news.md`: dated decisions in his words, labeled "his decision" or "his instruction";
  - Slack approval cards (AP-####) and a list of approved proposals;
  - one project decision register;
  - superseded registers;
  - Agent Space's "Decisions recorded" in each project home;
  - rulings inline in PS Agent Space's AGENTS.md.

  All of them mark authority the same way: his quote, the date, and the kind of words. All follow the same two-key rule: a big decision needs it named to him plainly and a yes in his own words.
- **What goes wrong:** there is no single log. `news.md` is never pruned, and only one project has a register.

**11. Task queue.** What the agents have been asked to do, and its state.
- **Today:** PS Brain and Agent Space use the same task shape: id, status and owner, source (a link to the intake entry and his words), home, dated progress, and next action, split into Amir's and the agent's. Poker Skill engineering work lives on GitHub issues.
- **What goes wrong:**
  - PS Brain's rule is "one or two items in Now", but its Now section holds 115 tasks, many of them already done.
  - Header dates are a month stale.
  - One id is used for two tasks.

**12. Projects.** Why we are building it, its state, and everything about it.
- **Today:** all three keep a project home:
  - a README with owner, steward agent, start date, and Amir's founding decision quoted;
  - state, a work log, decisions, open questions for Amir, and links to every document.

  Specs live in Google Sheets copied from Amir's Spec Template (north star, intent, a ledger of current, later and dropped items, milestones, tasks, links). PS Agent Space's roadmap packs add a verbatim north-star quote and milestones.
- **What goes wrong:** the project indexes miss folders (10 of 34 in Agent Space), and they disagree with the task queue on status.

**13. Roadmap.** What is planned, in what order, and where each item stands.
- **Today:** PS Brain's roadmap says the grouping and items are Amir's, and agents propose changes rather than make them. PS Agent Space marks items "PROPOSED, awaiting Amir". The status board of record is a tab in the Growth Playbook sheet.
- **What goes wrong:**
  - Status cells grow into paragraphs of release history.
  - PS Agent Space's roadmap index lists no September or October packs.
  - Three places claim to hold status: GitHub, the sheet tab and `plans/README.md`.

**14. Plans.** A proposed change and its blast radius, then how it went.
- **Today:** PS Agent Space and Agent Space share a lifecycle of drafts, then executed, then retros. Each plan answers why, evidence, proposed change, blast radius, success criteria and stop lines. Executed plans get an execution log, and retros record what happened and what to change next time.
- **What goes wrong:**
  - `drafts/` turns into a scratch area: 604 entries in PS Agent Space.
  - Only about a quarter of executed plans get a retro.

**15. Bugs and regressions.** What broke, why, how it was fixed, and what would have caught it.
- **Today:** GitHub issues are the board in all three. Beside them:
  - PS Agent Space's `REGRESSIONS.md` entry gives the symptom, the cause and its class, evidence, the repair, and "would have caught".
  - PS Brain keeps a `breaks.md` per agent, plus a ledger of wrong bug filings that agents must read before filing.
  - Issue claims use the `agent-in-progress` label plus a comment, and a claim lapses after a day without word.
- **What goes wrong:** one bug can appear in four places: GitHub, `REGRESSIONS.md`, `docs/bugs/` and the retired Morning Watch list.

**16. Experiments and forecasts (PS Brain only).**
- **Experiments:** every experiment is logged with the money question it answers, the metric that decides it, the decision date, the stop rule and whose decision it is.
- **Forecasts:** a forecast is never rewritten. A later one is a new row, with what it rested on and what actually happened. Worth keeping for every company.

### Accumulated working knowledge

**17. Lessons from Amir's corrections.** What he corrected and how to act differently.
- **Today:** a `shared/feedback.md` in PS Brain (about 218 sections) and in Agent Space (part copied from PS Brain). Each entry gives Amir's words, the lesson and how to apply it. PS Brain also keeps one `corrections.md` per agent. Claude's own memory, outside the repos, holds 193 files for PS Brain and 41 for Agent Space.
- **Shared rule:** fold a new correction into the lesson it changes rather than stacking another exception.
- **What goes wrong:**
  - Agents are told that a line in Claude memory "is not his ruling."
  - Agent Space's CLAUDE.md cites memory files that do not exist.

**18. Mistakes.** What went wrong, what it cost, and how to think next time.
- **Today:** PS Brain's `mistakes-retro.md` entry has what Amir saw, what happened, what it cost, and how to think about it next time. PS Agent Space's puzzle construction ledger is the richest version:
  - the underlying cause and its kind, including "acting without Amir's own words" and "telling Amir something unchecked";
  - who found it, its cost and the systematic fix;
  - status: Open, Fix untested, Fix held or Recurred.

**19. Agent learnings.** Patterns an agent has noticed in its own area.
- **Today:** a `learnings.md` per agent and specialist in PS Brain and Agent Space. Each pattern has when it was first seen, the evidence, a confidence, and what later data did to it.

**20. Research.** Dated, sourced answers to a question.
- **Today:** all three keep dated research notes that link their sources. PS Agent Space's index maps each question to where to start. Shared rule: when newer evidence overturns a note, mark the old one superseded and never rewrite it.
- **What goes wrong:** being superseded is marked by hand, in different ways, and often not at all.

**21. Change log and business events.** What changed, when, on whose authority, and how it was checked.
- **Today:**
  - **PS Agent Space `LOG.md`:** every externally visible change, with Amir's authorizing words, commits, PRs and a check-back.
  - **PS Agent Space `EVENTS.md`:** a curated timeline of the events that explain a bend in a chart, with the effective date versus the date it was found. It is mirrored into the warehouse.
  - **Agent Space's site changelog:** status (live, deployed, preview, rolled back), surface, the human owner, and the agent.
  - **PS Brain:** a `changes.md` per agent recording what changed, who changed it, what it was meant to do, when it is first readable and what the reading found. The CFO ledger adds money saved, approved-by, and how to undo.
- **What goes wrong:** at 1.7 MB, `LOG.md` is past reading, and it overlaps with `EVENTS.md`.

**22. Document and link index.** Every document anyone made or used, so nothing is lost.
- **Today:** PS Brain's `workspace-documents.md` gives each document an id (W1 to W537) with its link, system, creator, what it is and its record path. PS Agent Space's `SHARES.md` lists every published link. Agent Space links documents from project homes.
- **What goes wrong:** the files run 834 KB and 768 KB.

### Coordination

**23. Reports.** What each report is, who produces it, how often, who receives it, and what came back.
- **Today:**
  - **PS Brain:** each agent keeps dated report folders with a handback to its lead, and an `updates.md` ledger of what Amir received and what he said back. A schedules file and a lanes file record which agent owns each subject. A Slides deck explains how the morning reports work.
  - **PS Agent Space:** has a Monday update and several report skills.
  - **Agent Space:** its morning report is planned but not built.
- **What goes wrong:** no workspace has a registry of all reports.

**24. Who is on what.** Which agent is working on which thing right now, and handoffs between agents.
- **Today:** nothing records this directly. The proxies are:
  - the GitHub claim label;
  - one worktree per effort;
  - run lines in the device log;
  - a row for every AI Manager launch;
  - plan work logs;
  - the watcher's per-session files, untouched since October 10.

  The shared-checkout rule is "reread affected files before writing." Agent Space says a note left in another agent's folder is not a handoff, but it has no other handoff channel than GitHub issues.

**25. Watcher records and intent ledgers.**
- **Watcher records:** PS Brain's watcher keeps Amir's standing preferences, one file per watched session ("his ask and why, in his words"), and a time-stamped log of what it did and why.
- **Intent ledgers:** milestone runs keep a ledger of Amir's verbatim words. Its rule: "The only intent authority is Amir's own words … a replacement intent police can re-anchor from this file alone."

### Human views and access

**26. Google Sheets as the human view.** The metric catalog, roadmap and status tabs, decisions tabs, the CFO, experiment and opportunity ledgers, spec sheets, and the bots and venues reference.
- **Today:** PS Agent Space registers every script that writes to a sheet, with the ranges it owns and how often it runs. Decisions tabs leave the decision column blank for Amir.
- **What goes wrong:** status authority gets split between a sheet and the files.

**27. Skills as the way in.**
- **Today:** the elements that work best are the ones behind a skill: `$word-list`, `$canonical-data`, the access-check skills, the site worklog and the business ledger. Each workspace carries 220 to 254 skills, mirrored between `.claude/skills` and `.agents/skills`.

## Fields that recur on every kind of record

| Field | Seen as |
|---|---|
| Date | Date in the filename or heading; "as of", "last verified", "first seen"; effective date versus date found |
| Authority | Amir's words verbatim, the date and time, and the kind of words: his decision, his instruction, a "sure" to an agent's message, a passing thought, ruled, proposed, or an agent's own call |
| Owner | The human owner and the steward agent ("Owner: Amir · Run by: Chief") |
| Status | A different set of words in every file |
| Next action | Split into what is Amir's and what is the agent's |
| Evidence | A link to the query, PR, issue, Slack message or receipt |
| Confidence | On learnings, research sources and model rows |
| Superseded | "What overtook it, on whose word": always hand-written, never a field |
| IDs | C-### and CJ-### tasks, W### documents, AP-#### approvals, metric keys, GitHub numbers |
| Recurrence | "Recurred", "second time = escalate", "would have caught" |

## What goes wrong in all three

These are the failures the data design has to prevent.

1. **Ledgers grow past readable.** Examples:

   | File | Size |
   |---|---|
   | `REGRESSIONS.md` | 4 MB |
   | `LOG.md` | 1.7 MB |
   | `workspace-documents.md` | 834 KB |
   | `SHARES.md` | 768 KB |
   | `GOTCHAS.md` | 754 KB |
   | Agent Space site changelog | 683 KB |
   | Watcher log | 675 KB |
   | PS Brain `feedback.md` | 372 KB |
   | `mistakes-retro.md` | 343 KB |
   | PS Brain task queue | 294 KB |

   Agents are told to read "the parts that touch your area".
2. **Ordering breaks under many writers.** "Newest first" files have recent entries at both ends: `GOTCHAS.md`, `LOG.md`, `REGRESSIONS.md` and `mistakes-retro.md`.
3. **Indexes drift from what they index.** Intake, project and roadmap indexes miss entries. Task-queue header dates are weeks stale.
4. **Copies disagree.**
   - Event definitions restated outside the word list now conflict with it.
   - Poker Skill has two access maps.
   - Values and feedback are copied between companies by hand.
   - Business snapshots still quote figures the metric catalog has corrected.
5. **Nothing marks a record superseded.** Agents are taught that dated documents are evidence, not current state, because the documents cannot say so themselves.
6. **Decisions are scattered** across news, approval cards, registers, project homes, doctrine and memory.
7. **No live state:** nothing says who is working on what right now, or which reports run and when they last ran.
8. **Knowledge in private memory.** Claude's memory, kept outside the repos, holds rules other agents cannot see and are told not to trust.
9. **Status words differ in every file.** Examples: Now / Next / Parked / Done; live / deployed / preview; Open / Resolved / Disproven; Open / Fix untested / Recurred.
