# Notes

Amir's notes from the discovery stage, in the order he gave them. `BACKGROUND.md` has his starting thoughts and the top-level goal.

## 2026-10-26

- **Definitions are part of the data model.** For each term: how we define it, and the words we use for it. The data structures support this directly.
- **Start with data design.** Talk through everything we want the base to hold: what's in these notes, plus the canonical definitions, the metrics and how to get them, and the vocabulary list.
- **Mine the existing workspaces.** psbrain, agentspace and psagentspace already keep a lot of this. Find what they have in common and start the list from it.
- **Scope, first pass.** Amir sorted the elements into what's in, out and not yet decided. The result is in `ELEMENTS.md`.
- **A top level for Amir himself:** values, preferences, communication preferences and mistakes.
- **Change log needs exact rules.** It's in scope, but we have to get very specific about what goes there and what doesn't.
- **Specialist agents are their own category.** These are role-based agents: what each one is responsible for, and its purview.
- **Per-agent records wait.** Amir isn't sure what architecture he wants for per-agent records, one per agent or per session. He isn't confident yet about Sheets views or skills as the way in either.
- **The database is Postgres, probably on Fly.** Host it next to AI Manager, which already runs Fly Redis. It needs to be simple, and other people need to be able to connect to it.
- **Build the initial database schema now.** The whole system is Python, and the schema changes through migrations. Plan the schema first, get one round of review from GPT-6 Astra at xhigh, then stand the database up on a test machine on the network and stop.
- **Rules, intuitions and data are different kinds of knowledge.** Much of what agents need to store is intuitions: Amir's learnings and corrections kept as whole lessons. Agents turn those into rules instead, and the piles of rules end up contradicting each other and become a mess. Each element should say which kind of knowledge it holds.
- **"Knowledge Types" is its own document.** A knowledge type is different from a data type. The document maps each element to rule, intuition or data, with real examples from the workspaces for Amir to review.
- **Companies have domains.** Cratejoy has a seller domain and a coding-agent domain; Poker Skill has paid acquisition. Without domains, lessons that belong to an area end up at the top level. Example: "keep sellers' products listed" was filed under Amir's preferences, but it isn't about Amir; it belongs to Cratejoy's seller domain.
- **Not sure projects sit under domains.** The hierarchy needs real examples of domains and projects from the workspaces to settle it.
- **Exploration gets mistaken for the plan.** A session ideates with Amir and builds decks, sheets or docs. Other agents find them and take them for the plan: an approval request to build something he didn't like, or the idea put on the forecast as something we're building. Projects need a lifecycle, something like:
  - just an idea with materials, maybe forecasts, that he doesn't want to do;
  - being implemented;
  - implemented, and being watched for bugs and fixes;
  - live for a long time, now only a historical record.

  He isn't sure what level the lifecycle lives at.
