# State Models

## Intent

Where a Destination's view state, business logic, and event handling live. Narrative detail: https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/UserGuide.md ("State Model").

## Core rules

- An `@Observable final class` conforming to `StateModeling`. Holds all view state and business logic; the View contains layout only.
- `handleEvent(_:content:)` switches on the event and either handles it internally or calls the Destination.
- Use the lifecycle hooks instead of the View's `onAppear`/`onDisappear`.
- Capture `[weak destination]` in closures and `Task`s.
- Views with no state or custom events use `DefaultDestinationState`; see `references/views.md`.

## Example: state model with an Interactor request and a presentation

```swift
@Observable
final class ColorsListState: StateModeling {
    typealias Destination = ColorsListView.Destination
    typealias EventType = ColorsListView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var items: [ColorViewModel] = []
    var selectedItem: ColorViewModel.ID?

    func handleEvent(_ type: EventType, content: ContentType? = nil) {
        switch type {
            case .retrieveInitialColors, .moreButton:
                Task { await requestColors(type: type) }
            case .color:
                // presentations use the throwing sync performAction
                destination?.handleThrowable { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                }
        }
    }

    private func requestColors(type: EventType) async {
        let result = await destination?.performAction(for: type, content: .colorsRequest(requestModel: .numColorsToRetrieve(5)))
        switch result {
            case .success(let content):
                if case .colors(models: let models) = content {
                    items = models
                }
            case .failure(let error):
                DestinationsSupport.logger.log("error \(error.localizedDescription)", category: .error)
            case .none:
                break
        }
    }

    func prepareForAppearance(isVisible: Bool) {
        guard isVisible else { return }
        handleEvent(.retrieveInitialColors)
    }
}
```

## Example: swappable state via a protocol

```swift
@MainActor protocol ColorsListStateModeling: StateModeling, AnyObject where Destination == ColorsListView.Destination {
    var items: [ColorViewModel] { get set }
    var selectedItem: ColorViewModel.ID? { get set }
}

// The interface state object holds `var stateModel: any ColorsListStateModeling`,
// so a mock or A/B variant can be passed in by the Provider.
```

## Example: cancelling work on removal

```swift
var downloadTask: Task<Void, Never>?

func cleanupResources() {
    downloadTask?.cancel()
}
```

## Lifecycle hooks (all optional)

| Hook | When |
| --- | --- |
| `prepareForPresentation()` | Once, when the Flow first presents the Destination, before its UI is built. Only add code here that should only run once. Can be used for initial setup work. |
| `prepareForAppearance(isVisible:)` | Each time the UI becomes active. Put state refresh work here. Put it inside an `isVisible` check if it should only run when View is actually on-screen |
| `prepareForDisappearance(wasVisible:)` | Each time the UI becomes inactive |
| `configureInteractor(_:type:)` | Once per attached Interactor, after the Provider builds the Destination. Only for setup the Interactor itself needs, e.g. starting a camera capture session; request initial content in `prepareForAppearance(isVisible:)` |
| `cleanupResources()` | The Destination is being removed from the Flow |

## Pitfalls

- `SheetPresenting` on the View instead of the state model.
- New Interactor requests implementing `handleInteractorResult`/`handleAsyncInteractorResult` instead of awaiting `performAction`.
- Long-running tasks not cancelled in `cleanupResources()`.
