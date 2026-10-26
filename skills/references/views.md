# Views

## Intent

A Destination's SwiftUI View, its interface state object, its Event enum, and the Destinations view modifiers. Narrative detail: https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/UserGuide.md ("Destination", "ViewModifiers").

## Core rules

- The only functions that should exist on Views should be related to layout. Business logic, Interactor calls, and presenting other Destinations should be handled by sending events to `stateModel.handleEvent(.event, content:)`.
- Capture the state model weakly in View closures (`Button`, `.onChange`, etc.): `{ [weak stateModel] in stateModel?.handleEvent(.event) }`. Exception: closures inside `List`/`ForEach` rows capture it normally, since the row closure already holds it strongly and a weak capture there only triggers a compiler warning.
- Conform the View to the protocol matching its container: `ViewDestinationInterfacing` (plain), `NavigatingDestinationInterfacing` (`NavigationStack`), `TabBarViewDestinationInterfacing` (`TabView`), `NavigationSplitViewDestinationInterfacing` (`NavigationSplitView`).
- Store the interface state object as `@State var destinationState`, created in the View's init.
- The interface state object is the home for the `Events` and `InteractorType` enums and the `Destination` typealias.
- The Provider's `assignAssociatedView` connects the View's state model to the Destination; don't assign it yourself.
- Pass data with an event through `content:` (the Destination's `ContentType`), not associated values on Event cases.

## Example: plain View with interface state

```swift
@Observable
final class ColorDetailInterfaceState: DestinationStateable, DestinationTypes {

    enum Events: String, EventTypeable {
        case colorDetailButton
    }

    enum InteractorType: InteractorTypeable {
        case colors
    }

    typealias Destination = ViewDestination<ColorDetailView, Events, DestinationType, AppContentType, TabType, InteractorType>

    var destination: Destination
    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
    }
}

struct ColorDetailView: ViewDestinationInterfacing, DestinationTypes {
    typealias Destination = ColorDetailInterfaceState.Destination
    typealias EventType = ColorDetailInterfaceState.Events
    typealias InteractorType = ColorDetailInterfaceState.InteractorType

    @State var destinationState: ColorDetailInterfaceState

    init(destination: Destination, state: ColorDetailState) {
        self.destinationState = ColorDetailInterfaceState(destination: destination, state: state)
    }

    var body: some View {
        VStack {
            Text("Color \(stateModel.colorModel?.name ?? "")")
            Button("Present") { [weak stateModel] in
                stateModel?.handleEvent(.colorDetailButton)
            }
        }
        .destinationSheet(presentation: stateModel.sheetPresentation)
    }
}
```

## Example: NavigationStack View

The interface state object conforms to `NavigationDestinationStateable` and owns the navigator. Every pushed View gets `.onDestinationDisappear`.

```swift
@Observable
final class ColorsListInterfaceState: NavigationDestinationStateable, DestinationTypes {
    // Events, InteractorType...
    typealias Destination = NavigationViewDestination<Events, ColorsListView, RouteDestinationType, AppContentType, AppTabType, InteractorType>

    var destination: Destination
    var navigator: any DestinationPathNavigating = DestinationNavigator()
    var stateModel: any ColorsListStateModeling

    init(destination: Destination, state: any ColorsListStateModeling) {
        self.destination = destination
        self.stateModel = state
        navigator.navigatorDestinationID = destination.id
    }
}

struct ColorsListView: NavigatingDestinationInterfacing, DestinationTypes {
    // typealiases, @State destinationState, init...

    var body: some View {
        NavigationStack(path: $destinationState.navigator.navigationPath) {
            List(stateModel.items, selection: $destinationState.stateModel.selectedItem) { item in
                ColorsListRow(item: item)
            }
            .navigationDestination(for: UUID.self) { [weak destination = destination()] destinationID in
                if let child = destination?.childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                    buildView(for: child)
                }
            }
        }
    }

    @ViewBuilder func buildView(for child: any ViewDestinationable<DestinationType, ContentType, TabType>) -> (some View)? {
        destinationView(for: child)
            .id(child.id.uuidString)
            .onDestinationDisappear(destination: child, navigationDestination: destination())
            .goBackButton {
                backToPreviousDestination(currentDestination: child)
            }
    }
}
```

## Example: TabView with no custom state

```swift
struct AppTabView: TabBarViewDestinationInterfacing, DestinationTypes {
    enum Events: EventTypeable {
        var rawValue: String { "" }
    }

    typealias EventType = Events
    typealias Destination = TabViewDestination<Self, EventType, DestinationType, ContentType, TabType, InteractorType>

    @State var destinationState: DestinationInterfaceState<Destination>

    init(destination: Destination) {
        let state = DefaultDestinationState(destination: destination)
        self.destinationState = DestinationInterfaceState(destination: destination, state: state)
    }

    var body: some View {
        TabView(selection: $destinationState.destination.selectedTab) {
            ForEach($destinationState.destination.activeTabs, id: \.self) { tab in
                if let tabDestination = destination().rootDestination(for: tab.wrappedValue.type),
                   let view = tabDestination.currentView() {
                    AnyView(view)
                        .id(tabDestination.id)
                        .tag(tab.wrappedValue.type.tabName)
                        .tabItem { Label(tab.wrappedValue.type.tabName, systemImage: tab.wrappedValue.type.imageName) }
                }
            }
        }
    }
}
```

## Event enums

- `EventTypeable` requires `Hashable`, `CaseIterable`, `Sendable`, and `var rawValue: String`. Plain cases: `enum Events: String, EventTypeable`.
- Every case must be bound to exactly one presentation or Interactor configuration in the Provider; the Flow's preflight check asserts on unbound cases. Cases the state model handles itself go in the Provider's `preflightIgnoredEvents`.
- A Destination with no events still declares `enum Events: EventTypeable { var rawValue: String { "" } }`.
- `@AutoCaseIterable` synthesizes `CaseIterable` for enums with associated values.

## View modifiers

- `.onDestinationDisappear(destination:navigationDestination:action:)` — on every View pushed in a `NavigationStack`.
- `.goBackButton(buttonImage:useGlassBackground:selectionAction:)` — custom back button; call `backToPreviousDestination(currentDestination:)`.
- `.destinationSheet(presentation: stateModel.sheetPresentation)` — on a View whose state model conforms to `SheetPresenting`.

## Pitfalls

- Business logic in a View instead of in the state model.
- Calling a state model method besides `handleEvent` from the View.
- Capturing `stateModel` strongly in a `Button` or other View closure (outside `List`/`ForEach` rows).
- `onAppear`/`onDisappear` for setup/teardown; use the state model's lifecycle hooks.
- Pushed Views missing `.onDestinationDisappear`, which leaves stale Destinations in the Flow.
- Boolean `@State` flags for sheets or navigation instead of Events bound to presentations.
- Associated values on Event cases instead of `content:`.
