# Knowledge types

What kind of knowledge each element in `ELEMENTS.md` holds. This is different from its data type: a data type says how a value is stored, while a knowledge type says how an agent should use it.

## The three types

- **Rule:** a fixed answer that doesn't depend on the case, such as a name, a definition or a role. A plain rule is the right tool for these.
- **Intuition:** an understanding of what matters and why, so an agent makes the right call in a case nobody described. Amir's corrections belong here, as whole lessons.
- **Data:** what is true or what happened, dated and checkable. Agents read it; they don't obey it.

Why this matters: agents turn Amir's corrections into rules. Each rule is right for the case that prompted it, and the next case brings another rule beside it. The piles end up contradicting each other. A correction should change an intuition, not add a rule.

## The mapping

Numbers match `ELEMENTS.md`.

**You**

| # | Element | Knowledge type | Why |
|---|---|---|---|
| 1 | Values | Intuition | What Amir cares about and why, applied to cases he never described |
| 2 | Preferences | Intuition | His corrections, kept as whole lessons. Today this is the biggest rule pile (218 sections in PS Brain) |
| 3 | Communication preferences | Intuition | How to write so he can act. A few format facts inside it are plain rules, such as putting the id beside a name as a link |
| 4 | Mistakes | Data | What happened and what it cost. Its lesson belongs in 2 or 3, not in a new rule |

**Company**

| # | Element | Knowledge type | Why |
|---|---|---|---|
| 5 | Vocabulary | Rule | A name doesn't depend on the case |
| 6 | Metric catalog | Rule | One way to count each number. The reference value and when the query was last checked are data |
| 7 | Data gotchas | Data | A dated fact about a source: what's wrong, from when to when, the evidence |
| 8 | Systems and access | Data | Which route works and when it was last checked. It changes, so agents check it |
| 9 | Strategic goals | Rule | The target and how it's measured are fixed until Amir changes them |
| 10 | Roadmap | Data | What's planned and where each item stands |
| 11 | Change log and business events | Data | What changed and when |
| 12 | Reports | Data | What exists, who makes it, how often, what came back |

**Project**

| # | Element | Knowledge type | Why |
|---|---|---|---|
| 13 | Project home | Data, except "why we're building it", which is intuition | State, milestones and the work log are facts. The why is what lets an agent make calls inside the project |
| 14 | North star goals | Intuition | What the project is for, which agents use to judge drift |
| 15 | Plans | Data | The proposal, its blast radius, how it went |
| 16 | Bugs and regressions | Data | What broke and why. "What would have caught it" is a lesson that belongs in an intuition |
| 17 | Experiments | Data | The question, the result, the decision |
| 18 | Forecasts | Data | What we predicted and what happened |
| 19 | Research | Data | Dated findings with sources |

**Specialist agents**

| # | Element | Knowledge type | Why |
|---|---|---|---|
| 20 | Specialists | Rule | A role and its purview are fixed answers. How a specialist does the job well is intuition, and lives in its instructions |

## What follows from the mapping

1. **The lessons come out of the data.** Mistakes, bugs, plan retros and Amir's replies to reports are where lessons start. Today each lesson gets written as a new rule on its record, which is how the piles build up. In this design, the record stays data, and its lesson changes an existing intuition.
2. **Intuitions have no home below Amir's level.** Only You (1 to 3) and north stars (14) hold intuitions. A lesson about one company's own work has nowhere to go, for example how Poker Skill's paid ads behave. Per-agent learnings (row 26, not decided yet) was the closest fit.
3. **The schema invites the rule pile.** Every record in the database has a `guidance` field ("what an agent should do because of this record"), which asks agents to attach a rule to each fact. It is unchanged for now, and worth settling before any real data goes in.

Real examples of each element, taken from the workspaces, are kept out of this public repo because they quote internal material.
