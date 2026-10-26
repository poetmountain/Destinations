# Presentations

## Intent

Showing, replacing, or dismissing a Destination's UI. Narrative detail: https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/UserGuide.md ("Interface Presentations").

## Core rules

- Define each presentation as a `DestinationPresentation` and bind it to an Event in the Provider's `presentationsData`. Presentations can be reused across Providers.
- Trigger it from the state model with the throwing `performAction(for:content:)` inside `handleThrowable`. Never present from the View.
- `contentType` (or the `content:` passed with the event) supplies initial data to the presented Destination's Provider.
- `assistantType`: `.basic` normally; `.custom(any InterfaceActionConfiguring)` only to change the route at runtime.

## Example: navigation push bound to an Event

```swift
struct ColorsListProvider: ViewDestinationProviding, DestinationTypes {
    typealias Destination = ColorsListView.Destination
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    var interactorsData: [Destination.EventType: any InteractorConfiguring<Destination.InteractorType>] = [:]

    init() {
        let colorSelection = PresentationConfiguration(
            destinationType: .colorDetail,
            presentationType: .navigationStack(type: .present),
            assistantType: .basic)

        presentationsData = [.color: colorSelection]
    }
}

// State model:
destination?.handleThrowable { [weak destination] in
    try destination?.performAction(for: .color, content: .color(model: item))
}
```

## Example: reading presentation content in the target Provider

```swift
func buildDestination(destinationPresentations: ..., navigationPresentations: ..., configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
    var colorModel: ColorViewModel?
    if case let .color(model) = configuration.contentType {
        colorModel = model
    }
    let state = ColorDetailState(colorModel: colorModel)
    // ...
}
```

## Example: sheet

```swift
let options = ViewSheetPresentationOptions(presentationMode: .sheet)
let sheetPresent = DestinationPresentation<DestinationType, ContentType, TabType>(
    destinationType: .dynamic,
    presentationType: .sheet(type: .present, options: SheetPresentationOptions(swiftUI: options)),
    assistantType: .basic)
```

The presenting Destination's **state model** conforms to `SheetPresenting` (`var sheetPresentation = SheetPresentation()`), and its View applies `.destinationSheet(presentation: stateModel.sheetPresentation)`. Only one sheet per Destination at a time.

## Example: dismissing a sheet

For an app with a few sheets, give each sheet its own Destination and bind its Done Event to a dismiss in the sheet's Provider. The sheet's state model triggers it like any other presentation.

```swift
// Sheet's Provider
let dismiss = PresentationConfiguration(presentationType: .sheet(type: .dismiss), assistantType: .basic)
presentationsData = [.done: dismiss]
```

For an app with many sheets (SwiftUI), present them all through one dynamic sheet Destination instead. The presenting state model builds the sheet's View and passes it as content, with a dismissal closure that calls back to its own `sheetPresentation`. Then each sheet doesn't need its own Provider or dismiss presentation.

```swift
// Presenting state model (conforms to SheetPresenting)
private func showSheet(for type: EventType) {
    let sheetView = ContainerView {
        AnyView(
            ColorSheetView(colorModel: colorModel, dismissButtonClosure: { @MainActor [weak sheetPresentation] in
                sheetPresentation?.dismissSheet()
            })
        )
    }

    destination?.handleThrowable { [weak destination] in
        try destination?.performAction(for: type, content: .dynamicView(view: sheetView))
    }
}
```

The dynamic sheet's Provider reads `.dynamicView(view:)` from `configuration.contentType` and wraps it in a View with no Events. From the presenting state model, `destination?.dismissSheet()` also dismisses its sheet. Both shortcuts are SwiftUI only; UIKit Destinations have no `dismissSheet()`.

## Example: deep link path

```swift
let path: [PresentationConfiguration] = [
    PresentationConfiguration(presentationType: .tabBar(tab: .palettes), assistantType: .basic),  // select the tab
    PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present),
                              contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic)
]
let pathPresent = PresentationConfiguration(presentationType: .destinationPath(path: path), assistantType: .basic)
```

Navigation animations are disabled along a path unless a step sets `navigationStackOptions: NavigationStackPresentationOptions(shouldAnimate: true)`.

## Example: route assigned at runtime

Normally each `DestinationPresentation` has a fixed `destinationType`, which keeps routing type-safe. When the target isn't known until runtime (server-driven routing, user configuration), bind one presentation to the Event and let a custom presentation assistant override its `destinationType` from the event's content before the Flow presents it.

1. Give the app's `ContentType` a case that carries a route:

```swift
enum AppContentType: ContentTypeable {
    case route(Route)  // Route is the app's RoutableDestinations enum

    var rawValue: String {
        switch self {
            case .route: "route"
        }
    }
}
```

2. Write an assistant that reads the route and overrides the destination type:

```swift
struct DynamicRouteAssistant<EventType: EventTypeable>: InterfaceActionConfiguring, DestinationTypes {
    func configure(interfaceAction: InterfaceAction<EventType, DestinationType, ContentType>, eventType: EventType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<EventType, DestinationType, ContentType> {
        var action = interfaceAction
        action.data.parentID = destination.id

        if case .route(let route) = content {
            action.data.destinationType = route
        }
        return action
    }
}
```

3. Bind it in the Provider; the configured `destinationType` is the fallback route:

```swift
let navigatePresentation = PresentationConfiguration(
    destinationType: .welcome,
    presentationType: .navigationStack(type: .present),
    assistantType: .custom(DynamicRouteAssistant<Destination.EventType>()))

presentationsData = [.navigate: navigatePresentation]
```

4. Send the chosen route with the event from the state model:

```swift
var selectedRoute: Route = .welcome

func handleEvent(_ type: EventType, content: ContentType? = nil) {
    switch type {
        case .navigate:
            destination?.handleThrowable { [weak destination, weak self] in
                guard let self else { return }
                try destination?.performAction(for: type, content: .route(selectedRoute))
            }
    }
}
```

5. Register a Provider for every route the assistant can produce:

```swift
let providers: [Route: any ViewDestinationProviding] = [
    .dynamic: DynamicRouteProvider(),
    .welcome: WelcomeProvider(),
    .info: InfoProvider()
]
```

Notes:

- A custom assistant replaces `DefaultPresentationAssistant`, which sets `parentID` and copies the event's `content` into `contentType` when it's nil. Do both yourself if the presented Destination needs the content.
- The same approach works for runtime deep links: have the assistant (or state model) assemble a `destinationPath(path:)` from runtime data.
- Prefer a fixed `destinationType` whenever the route is known at compile time.

## Presentation types

| Type | Use |
| --- | --- |
| `navigationStack(type: .present / .goBack)` | Push/pop in `NavigationStack` / `UINavigationController` |
| `tabBar(tab:)` | Present in a tab; with no `destinationType` it only selects the tab |
| `splitView(column:)` | Present in a split view column |
| `sheet(type: .present / .dismiss, options:)` | Sheets; SwiftUI and UIKit options via `SheetPresentationOptions` |
| `replaceCurrent` | Replace the current Destination |
| `replaceRoot` | Remove all Destinations and set a new root (e.g. sign-out) |
| `moveToNearest` | Jump to the nearest ancestor of `destinationType` (required) |
| `destinationPath(path:)` | Chain of presentations; deep links |
| `addToCurrent` | UIKit only; child view controller |
| `custom(presentation:)` | Custom UI or unsupported system components |

## Pitfalls

- Awaiting the async `performAction` for a presentation Event. It presents, then returns `DestinationsError.presentationResultNotSupported` (not a presentation failure) because presentations have no result; this may change in a future version. Use the throwing sync version. Put post-presentation setup in the presented state model's `prepareForAppearance(isVisible:)`.
- Binding one Event to both a presentation and an Interactor configuration; preflight rejects it.
- Boolean flags to drive sheets or navigation instead of a presentation bound to an Event.
- `moveToNearest` without a `destinationType`.
