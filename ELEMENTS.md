# Elements of the knowledge base

What the knowledge base holds, grouped by level, with Amir's scope calls from 2026-10-26. The list comes from comparing what his three agent workspaces keep today (the comparison is at the end).

Which kind of knowledge each element holds (rule, intuition or data) is in `KNOWLEDGE_TYPES.md`.

## Scope

### In scope

**You** (about Amir; the same for every company and every agent)

| # | Element | What it holds |
|---|---|---|
| 1 | Values | What you care about, in your words, and how agents act on it |
| 2 | Preferences | How you want work done, learned from your corrections |
| 3 | Communication preferences | How agents write to you and for you |
| 4 | Mistakes | What went wrong, the underlying cause, what it cost, how to think next time |

**Company** (one set each for Poker Skill and Cratejoy)

| # | Element | What it holds |
|---|---|---|
| 5 | Vocabulary | What we call each thing, what it means, the words not to use, ruled or proposed |
| 6 | Metric catalog | One way to count each number: definition, who's counted, days, source, tested query |
| 7 | Data gotchas | Traps in a data source that make a number misleading, and how to handle them |
| 8 | Systems and access | Every system, the route that works, where the credential lives, when last verified |
| 9 | Strategic goals | The company's goals in your words, how each is measured, where the numbers come from |
| 10 | Roadmap | What's planned and where each item stands; yours vs agent-proposed |
| 11 | Change log and business events | What changed, when, on whose authority; the events that explain a bend in a chart. In scope, but where it lives and exactly what goes in it are still open |
| 12 | Reports | What each report is, who produces it, how often, who gets it, what came back |

**Project** (one set per project)

| # | Element | What it holds |
|---|---|---|
| 13 | Project home | Why we're building it, state, milestones, work log, linked documents |
| 14 | North star goals | The project's goal in your words, and how we'll know it's reached |
| 15 | Plans | A proposed change, its blast radius and stop lines, then how it went |
| 16 | Bugs and regressions | What broke, why, the fix, what would have caught it |
| 17 | Experiments | Each experiment's question, deciding metric, decision date, stop rule |
| 18 | Forecasts | What we predicted, what it rested on, and what actually happened |
| 19 | Research | Dated, sourced answers to a question; superseded, never rewritten |

**Specialist agents** (one entry per role-based specialist)

| # | Element | What it holds |
|---|---|---|
| 20 | Specialists | Each specialist's role, what it's responsible for, and its purview |

### Not decided yet

| # | Element | Where it stands |
|---|---|---|
| 21 | Task queue | Amir: not in scope yet |
| 22 | Market | Amir: maybe. Read here as the market a project serves: who it's for and what competes with it |
| 23 | Intake | Not ruled. An intake entry is where an agent saves Amir's exact words the moment he says something, before acting on it, then notes where they went (a task, a project, a ruling) |
| 24 | Runbooks | Not ruled |
| 25 | Documents | Not ruled. Every sheet, deck, money note and ledger anyone made or used, so nothing is lost |
| 26 | Per-agent records | Each agent's learnings, what it's working on now, the watcher's records. Amir: not sure what architecture he wants for these |
| 27 | How people and agents reach the data | Google Sheets views and skills. Amir: not yet, not confident he wants it |

### Out of scope

| # | Element |
|---|---|
| 28 | People |
| 29 | Decisions |

## In scope: what each element holds today

Where each element lives in the three workspaces now, the shape it has settled into, and what goes wrong with it.

### You

**1. Values.**
- **Today:** a table in PS Brain (`shared/amir-values.md`): each value, in your words, and how Chief helps. Agent Space has a hand copy with a note to "update both when Amir changes one."

**2. Preferences.**
- **Today:**
  - PS Brain and Agent Space each keep a `shared/feedback.md`. PS Brain's has about 218 sections, and Agent Space's is partly copied from PS Brain. Each entry gives your words, the lesson and how to apply it.
  - PS Brain also keeps one `corrections.md` per agent.
  - Claude's own memory, outside the repos, holds 193 files for PS Brain and 41 for Agent Space.
- **Shared rule:** fold a new correction into the preference it changes rather than stacking another exception.
- **What goes wrong:**
  - Agents are told that a line in Claude memory "is not his ruling."
  - Agent Space's CLAUDE.md cites memory files that do not exist.
  - The same preference is written in several places.

**3. Communication preferences.**
- **Today:**
  - the "Writing to Amir" section of the global `~/.claude/CLAUDE.md`;
  - in PS Brain: `shared/communication/` (analysis and decks), `knowledge/amir-voice.md` and `knowledge/slack-posts.md`, plus a `deck/feedback-log.md` per project deck recording your review rounds;
  - the `$readable-reports` and `$deck-authoring` skills.
- **What goes wrong:** the same rules are spread across a global file, workspace files, skills and Claude memory.

**4. Mistakes.**
- **Today:**
  - **PS Brain `shared/mistakes-retro.md`:** what you saw, what happened, what it cost, and how to think about it next time.
  - **PS Agent Space's puzzle construction ledger:** the richest version. It records the underlying cause and its kind, including "acting without Amir's own words" and "telling Amir something unchecked". It also records who found it, the cost, the systematic fix, and a status of Open, Fix untested, Fix held or Recurred.
  - **PS Agent Space `docs/UNSAFE_COMMANDS.md`:** teaches dated incidents.
  - **Agent Space:** keeps mistakes as plan retros.
- **What goes wrong:** `mistakes-retro.md` is 343 KB, and its "newest first" order has broken.

### Company

**5. Vocabulary.**
- **Today:** PS Brain's `$word-list` skill is the strongest version. Its columns are: what agents write, say instead, what it means, and status. Each name is marked **Ruled** (with the date you ruled) or **Proposed**. PS Agent Space links to that skill and says nothing in the repo may restate a name. Agent Space has no word list; its terms sit in a CLAUDE.md section, in lessons and in Claude memory.
- **What goes wrong:**
  - PS Agent Space restates event definitions anyway, and they now disagree: AGENTS.md says `InitiateCheckout` means checkout started, while `docs/CONTENT_AND_REPORTS.md` still gives the older meaning.
  - In PS Brain, the skill says its files are rebuilt from a project folder, but recent rulings were written straight into them.

**6. Metric catalog.**
- **Today:** the same `$canonical-data` skill in PS Brain (1,345 metrics) and Agent Space (467), with the same columns: definition, unit, users counted, days and clock, when it is complete, source, where the source stands, issues, query, reference value, and what it is not to be confused with. Each also has:
  - tested queries;
  - a "no good source" list of metrics that have no reliable source yet, with the fix and its issue;
  - a dated changes log;
  - a Google Sheet view.

  Both declare the skill the winner over any other file that counts a number differently.
- **What goes wrong:**
  - Dated business snapshots still quote figures the catalog has corrected.
  - PS Brain's reference files have not been rebuilt since October 16.

**7. Data gotchas.**
- **Today:**
  - **Agent Space `docs/DATA-GOTCHAS.md`** (about 81 entries): date range, metrics affected, what happened, symptoms, how to handle, evidence, and a status of Open, Resolved or Disproven.
  - **PS Agent Space `GOTCHAS.md`** (about 457 entries): written as "the trap / what it broke / the rule". It mixes data traps with tool traps.
- **What goes wrong:** both are single files read only in slices, and "newest first" no longer holds in either.

**8. Systems and access.**
- **Today:** all three keep one, with the same row shape: system, route, identity or credential location, status, and date verified. Each Agent Space specialist has a skill that re-checks its routes.
- **What goes wrong:** Poker Skill has two maps, PS Brain's and PS Agent Space's, and each points at the other.

**9. Strategic goals.**
- **Today:** PS Brain's `shared/strategy/goals.md` gives each goal in your words, the date you set it, how it is measured and where the numbers come from. A goals log records each goal you state, change or drop, and agents may add only their own reading, marked as theirs. Elsewhere there are only dated strategy snapshots.
- **What goes wrong:** the snapshots are never refreshed.

**10. Roadmap.**
- **Today:** PS Brain's `shared/product-roadmap.md` says the grouping and items are yours, and agents propose changes rather than make them. PS Agent Space marks items "PROPOSED, awaiting Amir". Its status board of record is a tab in the Growth Playbook sheet. Cratejoy's roadmap lives in Google Sheets.
- **What goes wrong:**
  - Status cells grow into paragraphs of release history.
  - PS Agent Space's roadmap index lists no September or October packs.
  - Three places claim to hold status: GitHub, the sheet tab and `plans/README.md`.

**11. Change log and business events.** In scope. Where it lives, and exactly what goes in and what stays out, are still to be decided.
- **Today:**
  - **PS Agent Space `LOG.md`:** every externally visible change, with your authorizing words, commits, PRs and a check-back.
  - **PS Agent Space `EVENTS.md`:** a curated timeline of the events that would explain a bend in a revenue, conversion or install chart, with the effective date versus the date it was found. It is mirrored into the warehouse.
  - **Agent Space's site changelog:** status (live, deployed, preview, rolled back), surface, the human owner, and the agent.
  - **PS Brain:** a `changes.md` per agent recording what changed, who changed it, what it was meant to do, and what the first reading found. The CFO ledger adds money saved, approved-by, and how to undo.
- **What goes wrong:** at 1.7 MB, `LOG.md` is past reading, and it overlaps with `EVENTS.md`.

**12. Reports.**
- **Today:**
  - **PS Brain:** each agent keeps dated report folders with a handback to its lead, and an `updates.md` ledger of what you received and what you said back. A schedules file records when each report runs, and a lanes file records which agent owns each subject. A Slides deck explains how the morning reports work.
  - **PS Agent Space:** has a Monday update and several report skills.
  - **Agent Space:** its morning report is planned but not built.
- **What goes wrong:** no workspace has one registry of all reports, saying who produces each, how often, and when it last ran.

### Project

**13. Project home.**
- **Today:** all three keep one:
  - a README with owner, steward agent, start date, and your founding decision quoted;
  - state, a work log, open questions for you, and links to every document.

  Specs live in Google Sheets copied from your Spec Template (north star, intent, a ledger of current, later and dropped items, milestones, tasks, links).
- **What goes wrong:** project indexes miss folders (10 of 34 in Agent Space), and they disagree with the task queue on status.

**14. North star goals.**
- **Today:** the north star row of each spec sheet built from your Spec Template. PS Agent Space's roadmap packs also open with a verbatim north-star quote and milestones.
- **What goes wrong:** it lives inside each spec or pack, so nothing lists every project's north star in one place.

**15. Plans.**
- **Today:** PS Agent Space and Agent Space share a lifecycle of drafts, then executed, then retros. Each plan answers why, evidence, proposed change, blast radius, success criteria and stop lines. Executed plans get an execution log, and retros record what happened and what to change next time. PS Brain keeps a `PLAN.md` per project.
- **What goes wrong:**
  - `drafts/` turns into a scratch area: 604 entries in PS Agent Space.
  - Only about a quarter of executed plans get a retro.

**16. Bugs and regressions.**
- **Today:** GitHub issues are the board in all three. Beside them:
  - PS Agent Space's `REGRESSIONS.md` entry gives the symptom, the cause and its class, evidence, the repair, and "would have caught".
  - PS Brain keeps a `breaks.md` per agent, plus a ledger of wrong bug filings that agents must read before filing.
  - Issue claims use the `agent-in-progress` label plus a comment, and a claim lapses after a day without word.
- **What goes wrong:** one bug can appear in four places, and `REGRESSIONS.md` is 4 MB.

**17. Experiments.**
- **Today (PS Brain only):** `agents/experiments/tests.md` logs every experiment with the money question it answers, the metric that decides it, the decision date, the stop rule and whose decision it is. Retros follow a template in `knowledge/experiment-retros.md`.

**18. Forecasts.**
- **Today (PS Brain only):** the growth quant's forecasts ledger. A forecast is never rewritten; a later one is a new row. Each row gives when it was made, what it forecasts, the range, what it rested on, when to read it, and what happened.

**19. Research.**
- **Today:** all three keep dated research notes that link their sources. PS Agent Space has 328 packs, indexed by question with where to start.
- **Shared rule:** when newer evidence overturns a note, mark the old one superseded and never rewrite it.
- **What goes wrong:** superseding is marked by hand, in different ways, and often not at all.

### Specialist agents

**20. Specialists.**
- **Today:**
  - **PS Brain:** nine specialists in `specialists/`: ads, ASO, CFO, lifecycle, onboarding and retention, SEO, social media, startup advisor and YouTube. About 35 morning-report agents sit in `agents/`. `.claude/skills/_shared/lanes.md` says which agent owns each subject ("a subject belongs to the agent that owns the decision it serves"). `kpis.md` lists each agent's KPIs, which you approved on October 9.
  - **Agent Space:** `specialists/README.md` is a roster of four specialists, each job in your words ("whose purview is all external merchandising"). Each has its own `CLAUDE.md`, `learnings.md`, `research/` and `work/` folders.
  - **PS Agent Space:** has 11 task agents in `.claude/agents/`, such as the copy writer and the ad audits. These are task helpers, not role specialists.
- **What goes wrong:**
  - The roster, the lanes, the KPIs and each specialist's own instructions are separate files.
  - Agent Space builds its specialists from PS Brain's runbook, so the two can drift.

## Fields that recur on every kind of record

| Field | Seen as |
|---|---|
| Date | Date in the filename or heading; "as of", "last verified", "first seen"; effective date versus date found |
| Authority | Your words verbatim, the date and time, and the kind of words: your decision, your instruction, a "sure" to an agent's message, a passing thought, ruled, proposed, or an agent's own call |
| Owner | The human owner and the steward agent ("Owner: Amir · Run by: Chief") |
| Status | A different set of words in every file |
| Next action | Split into what is yours and what is the agent's |
| Evidence | A link to the query, PR, issue, Slack message or receipt |
| Confidence | On learnings, research sources and model rows |
| Superseded | "What overtook it, on whose word": always hand-written, never a field |
| IDs | C-### and CJ-### tasks, W### documents, AP-#### approvals, metric keys, GitHub numbers |
| Recurrence | "Recurred", "second time = escalate", "would have caught" |

## The comparison behind this list

Compared on 2026-10-26:

- **PS Brain** (`~/workspace/psbrain`): Poker Skill's Chief, its agents and its specialists. It owns decisions, planning and company memory.
- **PS Agent Space** (`~/workspace/psagentspace`): Poker Skill's execution workspace. It owns data access, delivery and scripts, and in practice most of the big ledgers.
- **Agent Space** (`~/workspace/agentspace`): Cratejoy's Chief and four specialists. Its structure was copied by hand from PS Brain's.

All three keep the same kinds of record, and Agent Space matches PS Brain closely because it was cloned from it. These things break in all three, and the data design has to prevent them:

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
2. **Ordering breaks under many writers.** "Newest first" files have recent entries at both ends.
3. **Indexes drift from what they index.** Intake, project and roadmap indexes miss entries. Header dates are weeks stale.
4. **Copies disagree.**
   - Event definitions restated outside the word list now conflict with it.
   - Poker Skill has two access maps.
   - Values and preferences are copied between companies by hand.
   - Business snapshots quote figures the metric catalog has corrected.
5. **Nothing marks a record superseded.** Agents are taught that dated documents are evidence, not current state, because the documents cannot say so themselves.
6. **Knowledge in private memory.** Claude's memory, kept outside the repos, holds rules other agents cannot see and are told not to trust.
7. **Status words differ in every file.**
