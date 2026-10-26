# Providers

## Intent

Building a Destination and declaring what each of its Events does. The Flow asks a Provider for a Destination when one needs to be presented. Narrative detail: https://raw.githubusercontent.com/poetmountain/Destinations/main/Guides/UserGuide.md ("Provider", "Configure a Destination").

## Core rules

- One Provider per Destination type, conforming to `ViewDestinationProviding` (SwiftUI) or `ControllerDestinationProviding` (UIKit).
- `presentationsData` maps Events to `DestinationPresentation`s; `interactorsData` maps Events to `InteractorConfiguration`s (or Action Sequence configurations).
- Every Event case must appear in exactly one of the two dictionaries. When the Flow starts it calls `prepareForProviding()` on each Provider, which asserts on unbound Events and on Events bound in both. Events the state model handles itself go in `preflightIgnoredEvents`.
- `buildDestination` creates the Destination, state model, and View, calls `assignAssociatedView`, and attaches Interactors with `assignInteractor(_:to:)`. Nothing else: the framework assigns Interactor assistants and calls `configureInteractor` afterward.
- Read incoming data from `configuration.contentType` in `buildDestination`.
- Register each Provider in the Flow's `destinationProviders` dictionary under its destination type.

## Example: Provider with a presentation and Interactor requests

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

        let retrieve = InteractorConfiguration<Destination.InteractorType, ColorsInteractor>(
            interactorType: .colors,
            actionType: .retrieve,
            assistantType: .basicAsync)

        presentationsData = [.color: colorSelection]
        interactorsData = [.retrieveInitialColors: retrieve]
    }

    func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, AppContentType, TabType>?,
                          navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?,
                          configuration: PresentationConfiguration,
                          appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .colorsList,
                                      destinationConfigurations: destinationPresentations,
                                      navigationConfigurations: navigationPresentations,
                                      parentDestination: configuration.parentDestinationID)

        let state = ColorsListState(destination: destination)
        let view = ColorsListView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        destination.assignInteractor(ColorsInteractor(), to: .colors)

        return destination
    }
}
```

## Example: presentations injected by the app

When routing is decided at the app level (e.g. a deep link), pass `presentationsData` in instead of defining it inside the Provider. The Provider and its View stay unchanged when the route changes.

```swift
let homePathPresent = PresentationConfiguration(presentationType: .destinationPath(path: homePath), assistantType: .basic)
let homeProvider = HomeProvider(presentationsData: [.pathPresent: homePathPresent])
```

## Example: Events handled by the state model

```swift
struct SequenceDemoProvider: ViewDestinationProviding, DestinationTypes {
    // The state model builds this Event's Action Sequence at runtime.
    var preflightIgnoredEvents: [EventType] = [.retrieveAndSaveImages]
    // ...
}
```

## Example: container Provider building child Destinations

A tab bar Provider asks the Flow to build each tab's root Destination with `appFlow.buildDestination(for:)`.

```swift
func buildDestination(..., configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
    guard case let .tabBar(tabs: tabs)? = configuration.destinationType else { return nil }

    var tabDestinations: [any ViewDestinationable<DestinationType, ContentType, TabType>] = []
    for tab in tabs {
        let rootType: RouteDestinationType
        switch tab {
            case .palettes: rootType = .colorsList
            case .home: rootType = .home
            case .counter: rootType = .counter
        }
        let tabConfig = DestinationPresentation<DestinationType, ContentType, TabType>(
            destinationType: rootType,
            presentationType: .tabBar(tab: tab),
            assistantType: .basic)
        if let child = appFlow.buildDestination(for: tabConfig) {
            tabDestinations.append(child)
        }
    }

    guard let destination = Destination(type: .tabBar(tabs: tabs), tabDestinations: tabDestinations, tabTypes: tabs,
                                        selectedTab: tabs[0], navigationConfigurations: navigationPresentations) else { return nil }
    destination.assignAssociatedView(view: AppTabView(destination: destination))
    return destination
}
```

## Example: registering Providers with the Flow

Hold the Flow in `@State` on the App. `@StateObject` isn't needed; the UI updates on `replaceRoot` either way.

```swift
@main
struct MyApp: App, DestinationTypes {
    @State private var appFlow: ViewFlow<DestinationType, TabType, ContentType>?
    @State private var hasStartedAppFlow = false

    func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {
        let startingTabs: [AppTabType] = [.palettes, .home]
        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorsList: ColorsListProvider(),
            .colorDetail: ColorDetailProvider(),
            .tabBar(tabs: startingTabs): TabBarProvider()
        ]
        let startingDestination = PresentationConfiguration(destinationType: .tabBar(tabs: startingTabs), presentationType: .replaceCurrent, assistantType: .basic)
        return ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasStartedAppFlow {
                    appFlow?.startingDestinationView()
                }
            }
            .onAppear {
                guard !hasStartedAppFlow else { return }
                appFlow = buildAppFlow()
                appFlow?.start()
                hasStartedAppFlow = true
            }
        }
    }
}
```

## Design choices to keep

- Keep each Provider's `buildDestination` a pure construction step; no requests or business logic.
- Swap behavior by changing configurations in the Provider (a different presentation, datasource, or state model), not by editing the View.
- Pass a mock Interactor or alternate state model from the Provider for tests and A/B variants.

## Pitfalls

- An Event with no configuration and not in `preflightIgnoredEvents`, or bound to both a presentation and an Interactor.
- Forgetting `assignAssociatedView` or `assignInteractor` for an Interactor that `interactorsData` references.
- Calling `configureInteractor`/`configureInteractors()` from `buildDestination`.
- A Provider missing from the Flow's `destinationProviders`, so its destination type can't be presented.
