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
