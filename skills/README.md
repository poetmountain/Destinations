# Destinations agent skill

An agent skill that guides AI coding assistants when they build Swift app features with the [Destinations](https://github.com/poetmountain/Destinations) framework. It works with Claude Code, Xcode's coding assistant, and other agents that support the Agent Skills format.

Destinations' APIs are intentionally flexible, so there's leeway given to developers to accomplish a task within their apps. This skill steers agents toward the preferred patterns so that the code they write matches how the framework is designed to be used.

## What it covers

- Framework vocabulary: Flows, Destinations, Providers, state models, Events, Interactors, and Action Sequences
- Building Destinations in Providers and binding each Event to a presentation or an Interactor configuration
- State, business logic, and event handling
- Handling lifecycle for Destination views
- Async Interactor requests, content transformers, and serial, parallel, and branching Action Sequences
- Presentations: navigation stacks, tabs, sheets, dynamic routes, and other presentation types
- Project structure for new apps, and anti-patterns to avoid

The skill is a `SKILL.md` file with focused reference files in `references/`, which an agent reads only when a task needs them.

## Actions

- `/new-destination <Name>`: scaffolds an empty screen module in `Modules/<Name>/` (Provider, state model, and View), adds it to the app's destination types, registers it with the Flow, and builds. For example: `/new-destination Settings`.

In Claude Code the command appears as `/destinations:new-destination`. To build a screen with real behavior, describe it to the agent in your own words instead.

## Installation

### Claude Code

From your terminal:

```bash
claude plugin install destinations --marketplace poetmountain/Destinations
```

Or from inside a Claude Code session:

```text
/plugin install destinations --marketplace poetmountain/Destinations
```

The terminal command requires Claude Code 2.1.292 or later, and the session command requires 2.1.275 or later. To get a newer version of the skill later, run `claude plugin update destinations@poetmountain`.

### Xcode

In Xcode's Intelligence settings, open Plugins, choose Add from URL, and enter `https://github.com/poetmountain/Destinations`.

## What the skill does

The skill contains instructions only. It runs no code, hooks, or servers, and it collects no data. When a task calls for more detail, the agent may fetch the Destinations guides from `raw.githubusercontent.com/poetmountain/Destinations`.

## Compatibility

The guidance is written for Destinations 3.2.4 and later.

## License

MIT. See the [LICENSE](https://github.com/poetmountain/Destinations/blob/main/LICENSE.md) file in the Destinations repository.
