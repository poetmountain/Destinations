---
name: destinations
description: Use when writing, reviewing, or debugging Swift code that uses the Destinations framework — Destinationable, ViewDestination, ControllerDestination, Provider, Interactor, Flow, StateModeling, DestinationPresentation, InteractorConfiguration. Covers vocabulary, Provider construction, and preferred patterns among Destinations' intentionally flexible APIs.
---

# Destinations

A View/UIViewController never knows about other screens, datasources, or what an action does — it only sends an `EventType` to its state model via `handleEvent(_:content:)`. Presentation and Interactor wiring live in the Provider, keyed by event.

## Vocabulary

- **Flow** (`ViewFlow`/`ControllerFlow`) — owns all live Destinations, builds new ones via Providers. Handles all view navigation plumbing.
- **Destination** (`ViewDestination`/`ControllerDestination`) — coordinates one screen's routing/requests. Built once in a Provider, otherwise left alone.
- **Provider** — builds the Destination, state model, and view; assigns Interactors; maps events to `DestinationPresentation`/`InteractorConfiguration`.
- **State Model** (`StateModeling`) — owns View state, business logic, lifecycle hooks. The View observes this, not the Destination.
- **Event** (`EventTypeable`) — An enum type that is generally used to perform a Destination presentation or an Interactor request, which are called via configuration models bound to specific Event types in the Provider. Events are the foundation for decoupling the UI from the actions that the user interactions should trigger. Generally every Destination gets its own Event enum.
- **Interactor** — handles larger tasks (i.e. API requests or background tasks). Generally called via `performAction(for:content:)` which accesses an InteractorConfiguration assigned to an Event in the Provider. Always prefer using an async Interactor (`AsyncInteractable`) whenever possible.
- **Action Sequence** — multi-step Interactor workflow that should be used for chaining serial request chains or building large tasks from smaller ones (`ActionSequenceConfiguration`, `ActionGroupConfiguration`, `ActionBranchConfiguration`).

## Quick start

### Existing project

- Find the closest existing Provider / state model / View triad for a similar screen and follow its conventions.
- Check the app's shared type enums (destination types, content type, tab type, interactor types) before adding new ones.
- Add new behavior as an Event + configuration in the Provider rather than new logic in the View.

### New project

- Define the app-level enums (destination types, content type, tab type) first.
- Set up a `ViewFlow`/`ControllerFlow` at the app root with a starting `DestinationPresentation` and a `[DestinationType: Provider]` dictionary; see `references/providers.md`.
- Hold a `ViewFlow` in `@State` on the App, not `@StateObject`; the UI updates on `replaceRoot` with `@State`.
- Add Destinations one at a time using the workflow below.

- Each Destination's files should live together in a directory:
  - Provider
  - State Model
  - View
- And all of the Destination directories should live in a Modules directory
- Data models should live in one Models directory
- Interactors should all live in one Interactors directory
- Transformers should all live in one Transformers directory
- Types should all live in one Types directory
- Errors should all live in one Errors directory

## General rules

- Build the Destination, state model, and view in the Provider's `buildDestination`; call `assignAssociatedView` and `assignInteractor(_:to:)` for each Interactor, then return.
- Bind every Event case to exactly one presentation or Interactor configuration in the Provider; the Flow's preflight check asserts otherwise. Events the state model handles itself go in `preflightIgnoredEvents`.
- Handle Interactor requests via the async `performAction` (single `InteractorConfiguration`) or `performActions` (sequences and groups) call and its returned `Result`, or call the Interactor directly (lookup via `interactor(for:)`) if the user wishes to avoid an extra Event.
- Trigger presentations with the throwing `performAction(for:content:)` inside `handleThrowable`. The async `performAction` still presents but returns `presentationResultNotSupported`, since presentations have no result.
- Use the state model's `prepareForAppearance(isVisible:)`/`prepareForDisappearance(wasVisible:)` for setup/teardown code, not the View's unreliable `onAppear()`/`onDisappear()`. The `isVisible` flag denotes when the View is actually on-screen.
- Business logic, event handling, and state live on the state model. Views do layout only — including no direct calls to Interactors or other Destinations; route through `handleEvent` → state model → `performAction`.
- State lives in state model properties, not View state. State models are `@Observable`.
- Capture the state model weakly in View closures, e.g. a `Button` action sending `handleEvent`, except inside `List`/`ForEach` rows.
- `InteractorConfiguration.assistantType`: default `.basicAsync`; use `.transformer(request:result:)` when request/result content types differ from the Destination's; reserve `.custom` for genuinely custom logic (e.g. consuming an `AsyncStream`).
- `DestinationPresentation.assistantType` is a separate, simpler enum (`ActionAssistantType`): `.basic` normally, `.custom(assistant:)` only to pick a Destination type dynamically at runtime from event content.

## Where things go

| Scenario | Preferred pattern |
| --- | --- |
| View state | `@Observable` state model property |
| Setup/teardown on appear/disappear | `prepareForAppearance(isVisible:)` / `prepareForDisappearance(wasVisible:)` |
| Presentation | throwing `performAction(for:content:)` inside `handleThrowable` |
| Interactor result | `await destination.performAction(for:content:)` returned `Result` |
| Chain of related requests | `performActions` with an `ActionSequenceConfiguration`: static ones built in the Provider and bound to an Event; dynamic ones built in the state model |
| Parallel requests merged into one result | `performActions` with an `ActionGroupConfiguration`, bound directly to an Event |
| One-off Interactor call without an Event | `destination.interactor(for:)` |
| Interactor content types differ from Destination's | `.transformer(request:result:)` assistant |
| Dismiss a sheet | A few sheets: Done Event bound to `.sheet(type: .dismiss)` in the sheet's Provider. Many sheets (SwiftUI): one dynamic sheet Destination, with a dismissal closure passed in its content (see `references/presentations.md`) |
| Pick a presentation route at runtime | `ActionAssistantType.custom` presentation assistant (see `references/presentations.md`) |
| Initial content request | `prepareForAppearance(isVisible:)` on the state model |
| Setup the Interactor itself needs (e.g. a camera capture session) | `configureInteractor(_:type:)` on the state model |

## References

Read only the reference relevant to the task:

- `references/providers.md`: building Destinations, binding Events, preflight checks, registering with the Flow.
- `references/presentations.md`: presentation types, navigation/tab/sheet containers, runtime routing.
- `references/interactors.md`: async Interactors, requests, assistant types, direct Interactor access.
- `references/action-sequences.md`: chained, parallel, and branching Interactor workflows.
- `references/state-models.md`: state model rules and lifecycle hooks.
- `references/views.md`: View protocols, interface state objects, Event enums, Destinations view modifiers.

Reference snippets conform to `DestinationTypes`. This is not a framework protocol; it's an app-defined protocol of shared typealiases (`DestinationType`, `ContentType`, `TabType`, `InteractorType`), e.g. `protocol DestinationTypes { typealias DestinationType = Route; typealias ContentType = AppContentType; ... }`. Use the project's equivalent, or create one.

Narrative guides, fetched from GitHub when needed (they aren't bundled with this skill):

- https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/UserGuide.md: full walkthrough with code.
- https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/ActionSequenceGuide.md: Action Sequences in depth.
- https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/MigrationGuide3.0.md (and `MigrationGuide2.0.md`): breaking changes.

## Anti-patterns

- Business logic, Interactor calls, or routing decisions in the View.
- Using `onAppear`/`onDisappear` for setup/teardown instead of the state model lifecycle hooks.
- Implementing `handleInteractorResult`/`handleAsyncInteractorResult` for new code instead of awaiting `performAction`.
- Building a `.custom` Interactor assistant just to bridge mismatched content types.
- Putting business logic in a Destination subclass instead of the state model.

## Workflow for a new Destination

1. Define the Destination's `Events` and `InteractorType` enums, typically on its `DestinationStateable` interface state object, and add a case for it to the app's destination type enum.
2. Create an `@Observable` state model conforming to `StateModeling`; implement `handleEvent(_:content:)` and the lifecycle hooks it needs.
3. Build the View: hold the `DestinationStateable` object, observe the state model, send events via `handleEvent`. Layout only.
4. Write the Provider: fill `presentationsData` and `interactorsData`, then implement `buildDestination`.
5. Register the Provider in the Flow's providers dictionary under its destination type, and wire a presentation to it from an existing Destination's Provider.
6. Build and fix compiler errors before moving on.

Users can scaffold an empty Destination with the `/new-destination <Name>` action.

## Contributing to Destinations itself

- Preserve the "assign stores, post-build pass configures" split in `Destinationable.swift` and its conformances.
- Run framework tests via `Tests/SwiftUI/DestinationsSwiftUI.xcodeproj` / `Tests/UIKit/DestinationsUIKit.xcodeproj`, not `xcodebuild -scheme Destinations`.
