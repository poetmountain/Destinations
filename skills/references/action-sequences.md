# Action Sequences

## Intent

Multiple related Interactor requests run as one async unit: serial chains, parallel groups, and conditional branches. Narrative detail: https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/ActionSequenceGuide.md.

## When to use

- Several dependent requests (retrieve → process → save).
- Several requests in parallel, merged into one value.
- The next request depends on a runtime condition.
- A single request: use a plain `InteractorConfiguration` instead.

## Core rules

- Steps are `ActionConfiguration`s; give each an `identifier` (an enum case) if you'll read its result.
- `.step(_:inputTransformer:)` converts the *previous* step's output for this step; it has no effect on the first step. `.output()` is deprecated.
- Static sequences (the same steps every run) are built in the Provider and bound to an Event in `interactorsData`; run them with `performActions(for:content:)`. Either an `ActionSequenceConfiguration` or an `ActionGroupConfiguration` can be bound directly. Pass per-run data as the `content:`.
- Sequences that must be built dynamically (steps or step actions depend on runtime data, e.g. one download step per URL) are built in the state model and run with `performActions(configuration:content:)`; list their Event in the Provider's `preflightIgnoredEvents`. A missing Interactor then only surfaces as `DestinationsError.unregisteredInteractor` when run.
- `performActions` only runs `ActionCollectionConfiguring` types (sequences and groups). For an Event bound to a single `InteractorConfiguration`, use `performAction(for:content:)`; `performActions(for:content:)` returns `DestinationsError.incompatibleType` for it.
- Keep the enclosing `Task` and cancel it in `cleanupResources()`.

## Example: serial sequence

```swift
let retrieve = ActionConfiguration<AppInteractorType, AppContentType, NotesInteractor>(
    interactorType: .notes,
    action: .retrieve,
    assistant: .basicAsync,
    identifier: StepType.retrieve)

let save = ActionConfiguration<AppInteractorType, AppContentType, NotesInteractor>(
    interactorType: .notes,
    action: .save,
    assistant: .basicAsync,
    identifier: StepType.save)

let sequence = ActionSequenceConfiguration<AppInteractorType, AppContentType>()
    .step(retrieve)
    .step(save, inputTransformer: NotesTransformer())
```

## Example: parallel group feeding a branch

```swift
let downloads: [any ActionConfiguring<InteractorType, ContentType>] = urls.map { url in
    ActionSequenceConfiguration<InteractorType, ContentType>()
        .step(ActionConfiguration<InteractorType, ContentType, ImageRetrievalInteractor>(
            interactorType: .imageRetrieval, action: .retrieve(imageURL: url),
            assistant: .basicAsync, identifier: StepType.retrieveImage))
        .step(ActionConfiguration<InteractorType, ContentType, SaveToDiskInteractor>(
            interactorType: .imageSaver, action: .save,
            assistant: .basicAsync, identifier: StepType.saveImage),
              inputTransformer: ImageFileTransformer())
}

let group = ActionGroupConfiguration<InteractorType, ContentType>(
    actions: downloads,
    merger: RetrievedImagesMerger(),
    identifier: StepType.retrieveAndSaveImages)

let pipeline = ActionSequenceConfiguration<InteractorType, ContentType>()
    .step(group)
    .step(ActionBranchConfiguration(identifier: StepType.filterBranch)
        .branch(when: BooleanCondition(shouldFilterImages), action: filterImages, transformer: nil)
        .otherwise(.skip))
```

## Example: parallel group bound to an Event

```swift
// Provider
let loadDashboard = ActionGroupConfiguration<InteractorType, ContentType>(
    actions: [profileStep, notificationsStep, activityStep],
    merger: DashboardResultsMerger(),
    identifier: StepType.dashboard)

interactorsData = [.loadDashboard: loadDashboard]

// State model
let result = await destination?.performActions(for: .loadDashboard)
if case .success(let results) = result, case .dashboard(let data) = results.last(identifier: StepType.dashboard)?.content {
    // use data
}
```

## Example: merger

```swift
struct RetrievedImagesMerger: ActionResultsMerging {
    func merge(results: [ActionResult<AppContentType>]) throws -> AppContentType {
        let urls = results.flatMap { result -> [URL] in
            guard case .savedFiles(let urls) = result.content else { return [] }
            return urls
        }
        return .savedFiles(urls: urls)
    }
}
```

## Example: custom branch condition

```swift
struct HasImagesCondition: BranchConditionable {
    typealias ContentType = AppContentType

    func evaluate(content: AppContentType?) -> Bool {
        guard case .images(let images) = content else { return false }
        return !images.isEmpty
    }
}
```

Built-ins: `BooleanCondition`, `AllSatisfyCondition`, `AnySatisfyCondition`, and `.negated()` on any condition.

## Example: running, reading results, cancelling

```swift
var sequenceTask: Task<Void, Never>?

func run() {
    sequenceTask = Task { [weak self] in
        let result = await self?.destination?.performActions(configuration: pipeline, content: nil)
        switch result {
            case .success(let results):
                if let saved = results.last(identifier: StepType.saveImage) {
                    // saved.content
                }
            case .failure(let error):
                if case ActionError<ContentType>.failed(partialResults: let partial, error: let underlying) = error {
                    // a serial step failed (the chain stops there), or a transformer/merger threw
                } else if case ActionError<ContentType>.cancelled(partialResults: let partial) = error {
                    // the task was cancelled, a branch had no match, or a group child failed
                    // (the child's shouldEndParentTaskOnFailure decides whether siblings are cancelled
                    // immediately or run to completion first)
                }
            case .none:
                break
        }
    }
}

func cleanupResources() {
    sequenceTask?.cancel()
}
```

## Pitfalls

- Nesting `performAction` calls in result handlers instead of building a sequence.
- Calling `performActions(for:content:)` on an Event bound to a single `InteractorConfiguration`; use `performAction(for:content:)`.
- Wrapping a lone `ActionGroupConfiguration` in a one-step sequence just to bind it to an Event; bind the group directly.
- Building a static sequence in the state model; it belongs in the Provider, bound to its Event.
- Forgetting `preflightIgnoredEvents` for Events that trigger runtime-built sequences from a user interaction on the View which calls the state model's `handleEvent(_:content:)`.
- Not cancelling long sequences when the Destination is removed.
