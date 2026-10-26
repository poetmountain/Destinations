# Interactors

## Intent

Isolated work (API requests, datasources, background tasks) and the assistants that connect it to a Destination. Narrative detail: https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/UserGuide.md ("Interactor").

## Core rules

- Name Interactors with an `Interactor` suffix, e.g. `ReviewsInteractor`, and their request types with a `Request` suffix.
- Prefer `AsyncInteractable` (an `Actor`-constrained protocol, so implement it as an `actor`).
- Create the Interactor in the Provider's `buildDestination` and attach it with `assignInteractor(_:to:)`.
- Bind each action to an Event with `InteractorConfiguration` in the Provider's `interactorsData`.
- Call it from the state model with `await destination.performAction(for:content:)` and handle the returned `Result` inline.
- Default assistant: `.basicAsync` or `.transformer(request:result:)`. Use the transformer type when request and result content types differ from Destination's content type; `.custom` only for custom logic such as ongoing streams.
- Transformers should simply convert from one type to another, avoid complex logic so they can be reused.
- Request initial content in the state model's `prepareForAppearance(isVisible:)`. Use `configureInteractor(_:type:)` only for setup the Interactor itself needs, e.g. starting a camera capture session. Cancel in-flight work in `cleanupResources()`.

## Example: request type and async Interactor

The request and result use the Destination's content type, so `.basicAsync` needs no conversion. Destinations works with either one app-wide content type or Interactor-specific ones; default to the app's content type unless the app needs separate types.

```swift
struct ColorsRequest: InteractorRequestConfiguring {
    enum ActionType: InteractorRequestActionTypeable {
        case retrieve
        case paginate
    }
    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType

    let action: ActionType
    var numColorsToRetrieve: Int = 3

    init(action: ActionType) {
        self.action = action
    }

    init(action: ActionType, content: RequestContentType?) {
        self.action = action
        if case .colorsRequest(requestModel: .numColorsToRetrieve(let count)) = content {
            numColorsToRetrieve = count
        }
    }
}

actor ColorsInteractor: AsyncInteractable {
    typealias Request = ColorsRequest

    func perform(request: Request) async -> Result<AppContentType, Error> {
        switch request.action {
            case .retrieve, .paginate:
                let models = await retrieveColors(count: request.numColorsToRetrieve)
                return .success(.colors(models: models))
        }
    }
}
```

## Example: wiring in the Provider

```swift
init() {
    let retrieveAction = InteractorConfiguration<Destination.InteractorType, ColorsInteractor>(
        interactorType: .colors,
        actionType: .retrieve,
        assistantType: .basicAsync)

    interactorsData = [.retrieveInitialColors: retrieveAction]
}

func buildDestination(...) -> Destination? {
    // ...
    destination.assignInteractor(ColorsInteractor(), to: .colors)
    return destination
}
```

## Example: transformers for `.transformer`

When an Interactor uses its own request or result content types instead of the Destination's.

```swift
// Destination ContentType -> Request.RequestContentType
struct ColorsRequestTransformer: ContentTransformable {
    func transform(input: AppContentType) throws -> ColorsRequestContent {
        if case .colorsRequest(requestModel: let model) = input {
            return model
        }
        return .numColorsToRetrieve(3)
    }
}

// Request.ResultData -> Destination ContentType
struct ColorsResultTransformer: ContentTransformable {
    func transform(input: ColorsResult) throws -> AppContentType {
        switch input {
            case .retrievedColors(let models):
                return .colors(models: models)
        }
    }
}

// Provider
assistantType: .transformer(request: ColorsRequestTransformer(), result: ColorsResultTransformer())
```

Pass `nil` for a direction that needs no conversion.

## Example: calling the Interactor directly, without an Event

```swift
guard let interactor = destination?.interactor(for: .colors) as? any AsyncInteractable<ColorsRequest> else { return }
let result = await interactor.perform(request: ColorsRequest(action: .retrieve))
```

This bypasses the assistant and returns the raw `ResultData`. Use it when an extra Event isn't wanted, e.g. a `TaskGroup` of requests.

## Example: custom assistant for an ongoing stream

The one case where results arrive via `handleAsyncInteractorResult`, because values keep coming after the request returns.

```swift
struct CounterInteractorAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = CounterView.InteractorType
    typealias Request = CounterRequest

    let interactorType: InteractorType = .counter
    let requestMethod: InteractorRequestMethod = .async

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: AppContentType?) async where Destination.InteractorType == InteractorType {
        let request = CounterRequest(action: actionType)
        guard let interactor = destination.interactor(for: interactorType) as? CounterInteractor else { return }
        _ = await destination.performRequest(interactor: interactorType, request: request)
        guard let stream = await interactor.stream else { return }
        for await count in stream {
            await destination.handleAsyncInteractorResult(result: .success(.count(value: count, isFinished: false)), for: request)
        }
    }
}

// Provider: assistantType: .custom(CounterInteractorAssistant())
```

## Pitfalls

- `handleInteractorResult`/`handleAsyncInteractorResult` for one-shot requests instead of awaiting `performAction`.
- A `.custom` assistant just to bridge content types.
- Calling an Interactor from a View.
- Forgetting `[weak destination]` in `Task` closures.
