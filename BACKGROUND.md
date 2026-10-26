# Background

Amir's starting thoughts for this project, captured 2026-10-26.

## What this project is for

Make many coding agents operate as one coordinated organization, rather than separate sessions that rely on Amir to keep everything connected.

The top-level goal is to let many agents work autonomously across Amir's companies without losing shared context, repeating mistakes, or requiring him to coordinate every handoff.

In Amir's words: a highly specialized knowledge base built for complex coding agents doing many things across multiple projects. It keeps them coordinated, builds a central source of truth over time, and gives them clean, skill-based interfaces so it is easy for them to check in and understand where things stand. It is built primarily for agents; humans get views of it (Slack, Google Sheets) rather than a competing copy.

It is not primarily a wiki or a message board. It is shared organizational memory and coordination for agents. Success means less execution-level babysitting from Amir, fewer repeated corrections, and more of his time on strategic decisions.

## Five capabilities

1. **Shared understanding.** What each company and project is trying to accomplish, common terminology (term definitions: "this is what we call this"), and where authoritative data lives (for example, each company's best place to get certain metrics).
2. **Shared state.** Current priorities, roadmap, milestones, bugs, dependencies, ownership, and what each agent is doing. Clearly distinguish Amir's decisions from agent proposals, and completed work from claimed or planned work.
3. **Accumulated working knowledge.** Decisions and their reasoning, mistakes and learnings, development journals, worked examples, postmortems and processes. Agents should reuse experience, not merely retrieve facts. The corpus grows over time instead of staying in silos.
4. **Reliable coordination.** When one agent changes something, affected agents can discover it. Check-ins (heartbeats: "this agent should be on this thing right now") and Amir's watcher keep assignments and status current, while making stale or conflicting information visible. The point is to reorient agents to what we are actually trying to accomplish and prevent drift.
5. **Simple access.** Skills give agents clear ways to orient themselves, find context and contribute updates. Sheets and Slack give humans, including the rest of the team, a bird's-eye view of the same underlying information.

## Structure Amir described

- **Companies.** Some things apply across all companies.
- **Projects**, each with:
  - the product reason we are building it
  - related GitHub issues
  - working documents: spreadsheets, money notes, tariff ledger, and so on
  - bug lists
  - a roadmap, marking which items came from Amir and which were proposed by agents
  - mistakes and learnings
  - milestones
- **Reporting.** What reports exist and who produces them.
- **Definitions.** Shared terms.
- **Agent heartbeats.** What each agent is on right now.
- **Integrations.** Amir's watcher, Slack, Google Sheets.

## Raw notes

Amir's dictation, verbatim:

> I'm trying to think through how to give, you know, I have all these. I talked yesterday about this, like, how do I get my coding agents to be more coordinated and aware? And, like, in my head, like I'm imagining almost like a message board, but it's not a message board. It's more like a way of organizing knowledge into different levels, but it has structure to it. We have, like, you know, companies, right? And there's, like, stuff that I want across both companies. Like they should all have their chronological best place to get certain, like, metrics. Then there's, like, projects. They, like, within each project, there's, like, you know, the reason we're building it from a product perspective. There's, like, you know, all the various related GitHub issues and whatever. There's, like, a collection of things, like spreadsheets, you know, money notes, tariff ledger, whatever. There's, like, bug lists. There's, you know, a roadmap. Each roadmap has, like, stuff that, like, get proposed by agents versus stuff that's come from me, right? Like, then there's, like, mistakes and learnings, milestones, like all these things. And my thought process is, like, I work across multiple projects, multiple companies. And if I build a system that sort of has a structure of, like, organizing all this and then tells the agents where to go to get the information. Oh, the other thing is reporting that's a big thing, like what reporting is done and by whom, you know, that stuff. Like if I can structure all of this, I think the agents can work more autonomously, make fewer mistakes. And, like, one of the common things is one agent changes something and the other sort of loses track. But I think also, like, even having some level of heartbeating on it. So it's like, okay, this agent right now needs to be on this thing. It could be useful. And, yeah. I think it integrate into my watcher too. So my watcher function, all my agents could also be actually paying attention to it. It opens the door for a lot of possibilities, which is, like, how do we reorient to what we're actually trying to accomplish and prevent drift? And how do we coordinate across many projects and preserve, like, and create a corpus of knowledge that's growing over time, right? As opposed to silos. And then the other humans, others on my team, who literally need to, again, I could, human from views to this, so humans can coordinate as well, or we make it, right? You know, we're probably looking— like, I think... Hold on one sec. Take these notes down.
>
> Yeah. Well, the thought process is basically make— it's like a highly specialized Outlook base that is designed to be designed for complex coding agents that are doing many things across multiple projects, that I want to keep coordinated and want to, like, continue to build a central source of truth and then have clean interfaces for them. So it's, like, really easy for them to understand, like check in and understand. They're skill-based interfaces. And then I can imagine I can just build various things. Like we can sync it to Slack, we can sync it to a Google Sheets so humans get a bird's-eye view, but it's primarily built for agents. And I can imagine— oh yeah, definitions, like term definitions, like this is what we call this. Right? Yeah, that's another thing. Yeah. Well, these are my initial thoughts, like help me compile these into, like, I guess a lot of future ideas, but, like, what am I trying to accomplish top level?

("Outlook base" in the dictation is most likely "knowledge base".)
