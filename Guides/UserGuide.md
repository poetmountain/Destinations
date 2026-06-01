## Overview

Let's take a deeper look at how Destinations can help you reduce implementation time and free up your user interfaces to focus on surprising and delighting your users.

### Setup

To configure your app, `DestinationPresentation` objects should be created to define every Destination presentation a user can initiate. There's a few main properties to configure. 

* The `destinationType` property represents the type of Destination to be presented. This should be a value of an enum type of your choosing. Multiple presentations may use the same type. For instance, you could have a `.userProfile` type that is represented in two different `DestinationPresentation`s – presented in your app both in a Profile tab and also appearing in a sheet. This property is optional, but if you intend to display a new Destination then you'll need to define one.
* The `presentationType` property denotes how a Destination's interface should be presented in the UI, such as in a navigation stack or a sheet. Several types are available that represent system navigation type as well as custom behaviors. More information on each type is available in the [DestinationPresentation](#destinationpresentation) section.
* The `contentType` property allows you to pass in a content model to supply configuration data or initial data for the Destination's interface.
* The `assistantType` property allows you to define an assistant which provides additional configuration when the Destination is being presented. In most cases you can just use the `.basic` assistant which Destinations implements internally.

For Interactors, use `InteractorConfiguration` objects to define actions which can be requested from UI interactions.
* The `interactorType` property defines the type of Interactor to request an action from. The association between a specific Interactor and an interactor type is made when calling the `assignInteractor(interactor: type:)` method on a Destination.
* The `actionType` property defines the specific action of the interactor to be requested, represented by an enum type of your choosing and is scoped to individual Interactors.

These `DestinationPresentation`s and `InteractorConfiguration` objects are assigned to the `presentationsData` and `interactorsData` dictionaries respectively.
```swift
struct NotesListProvider: ViewDestinationProviding {

    typealias Destination = NotesView.Destination
    typealias TabType = Destination.TabType
    typealias ContentType = Destination.ContentType

    var presentationsData: [Destination.EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    init() {

        // presentations
        let noteSelection = DestinationPresentation<DestinationType, ContentType, TabType>(
                destinationType: .noteDetail, 
               presentationType: .navigationStack(type: .present), 
                  assistantType: .basic)

        presentationsData = [.noteButton: noteSelection]

        // interactor requests
        let colorsListRetrieveAction = InteractorConfiguration<Destination.InteractorType, ColorsDatasource>(
                interactorType: .colors, 
                    actionType: .retrieve, 
                 assistantType: .basicAsync)

        interactorsData = [.retrieveColors: colorsListRetrieveAction]

    }

    <.....>
}
```

### Interaction Flow

**User interaction → Destination → State Model → InterfaceAction → Interaction Assistant → Flow → new Destination**

One of the main responsibilities of Destinations is to handle the presentation of new views, typically triggered from a user interacting with a UI element. These Destination events are represented by `EventTypeable`-conforming enum types which are scoped to an individual Destination.

When a user interacts with one of these element types, the view should call `handleEvent(_:content:)` on the Destination, passing in the event type and an optional content type. The Destination forwards this on to its state model, which decides what to do for each event type, but typically would end by calling back to the Destination's `performAction(for:content:)` method to trigger the configured action. (Note that `performAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.)
```swift
// In a state model
func handleEvent(_ type: EventType, content: ContentType?) {
    switch type {
        case .moreButton:
            destination?.handleThrowable { [weak destination] in
                try destination?.performAction(for: type)
            }
        default: break
    }
}
```

Calling `performAction(for:)` on the Destination retrieves the configuration object assigned to that event and then runs the appropriate action.

The `Flow` object (which we'll talk about next) is called by the Destination and given the action to run. When presenting a new view it will try to find an existing Destination associated with that view type, or if one is not found, builds a new one using a Destination provider assigned to its type. The Destination's interface is then presented in the view hierarchy using the presentation type assigned to the `DestinationPresentation`'s `presentationType` property.

If the event type is instead associated with an Interactor request, the Destination retrieves the Interactor and sends the request.

### Flow

 Flows manage the creation, appearance, and removal of Destinations as a user navigates through the app. They are the single source of truth for what Destinations currently exist in the ecosystem. Typically you don't interact with them directly after they've been configured. You should almost always use either the `ViewFlow` or `ControllerFlow` classes for SwiftUI and UIKit apps respectively.

When creating a Flow object you supply it with a starting Destination, along with a list of Providers which can build all the supported Destination types. All Destination user interfaces which are presented will be attached from this starting Destination's interface. In the UI where you want to attach the Flow to (generally you want to do so at the root of your app's UI hierarchy), you can call `startingDestinationView()` on a `ViewFlow` (for SwiftUI apps) or `assignRoot(rootController: <some UIController>)` on a `ControllerFlow` (for UIKit apps) to attach the Flow's UI hierarchy to the app's interface.

This SwiftUI app sketch shows how simple it is to add a Flow object. Just assign to the Flow object the Providers for the Destination types you want to support, as well as providing the starting Destination, and then attach the Flow's interface root to the app's UI. Please see the example projects for full implementations.
```swift
@State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?
@State var hasStartedAppFlow = false

func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {
        ...
        
    let startingTabs: [TabType] = [.home, .userNotes]
    let startingType: DestinationType = .tabBar(tabs: startingTabs)
    let startingDestination = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
    
    let homeProvider = HomeProvider()
    let notesProvider = NotesProvider()
    let tabsProvider = TabsProvider()
    let providers: [DestinationType: any ViewDestinationProviding] = [
        .home: homeProvider, 
        .notes: notesProvider, 
        .tabBar: tabsProvider
    ]
    
    return ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
}    

var body: some Scene {
    WindowGroup {
        ZStack {
            if hasStartedAppFlow {
                appFlow?.startingDestinationView()
            }
        }
        .onAppear(perform: {
            if (hasStartedAppFlow == false) {
                self.appFlow = buildAppFlow()
                self.appFlow?.start()
                hasStartedAppFlow = true
            }
        })
    }
}
        
```

### Destination

A Destination represents a unique area in an app which can be navigated to by the user. In SwiftUI this is typically a fullscreen `View` object, and in UIKit it's a `UIViewController` class or subclass, but it can also contain a group of Destination objects such as a tab bar or a carousel. A Destination holds references to the UI element it's associated with, but it doesn't handle the particulars of laying out elements on the screen. Instead, the role of Destination objects in the ecosystem is to act as a coordinator – routing events between the UI, the state model, and the Flow, and managing the Destination's place in the navigation hierarchy.

In most cases you can use the included `ViewDestination` and `ControllerDestination` classes in SwiftUI or UIKit apps respectively, without having to build custom Destination objects.
 
 But for Destinations where you need to utilize Interactors or hold View state, you should create your own `DestinationStateable
` object that's attached to the interface, along with a paired state model conforming to `StateModeling`. The state model holds the business logic and view state for the Destination, and is where you should implement lifecycle methods like `prepareForPresentation`, `prepareForAppearance(isVisible: Bool)`, and `prepareForDisappearance(wasVisible: Bool)`. For SwiftUI these lifecycle hooks are a much more reliable way to setup and tear down state than relying on SwiftUI's `.onAppear` modifier. See the [State Model](#state-model) section below for details.

 There is a bidirectional connection between a Destination and its interface which is handled by a `DestinationStateable`-conforming object, as well as a bidirectional connection between a Destination and the state model. Destinations comes with a `DestinationInterfaceState` object which can be used for simple cases that don't need a custom state model, though typically you'll create your own class so the interface can observe properties on the state model directly. When a Destination is removed from the ecosystem, cleanup of these connections is done internally to ensure no retain cycles occur.

 The state object must be stored on the user interface and should be created in the initialization method, passing in its Destination and state model.
```swift
@State var destinationState: NotesInterfaceState

init(destination: Destination, state: NotesState) {
    self.destinationState = NotesInterfaceState(destination: destination, state: state)
}
```

You can access the Destination instance through this state object, but you can also use the shortcut method `destination()`.

Destinations comes with several default Destination classes to represent common UIKit and SwiftUI interface types:

#### UIKit

* `ControllerDestination` can be used to represent most `UIViewController`s in your UIKit apps. 
* `NavigationControllerDestination` can be used as a Destination for a `UINavigationController` class. 
* `TabBarControllerDestination` can be used as a Destination for a `UITabBarController` class. In the associated `UITabBarController` class which conforms to the `TabBarControllerDestinationInterfacing` protocol, you should implement the `customizeTabItem(tab: navigationController:)`. This method passes a`TabModel` object which contains a `type` property you supply and can use to configure the tabs.
* `SwiftUIContainerDestination` can be used as a Destination for a `SwiftUIContainerController`, which allows you to host SwiftUI content within UIKit via `UIHostingController` instance. The SwiftUI content is managed by a separate `ViewFlow` contained within the `SwiftUIContainerDestination`, and Destination presentation requests for new `View`s can even be sent from UIKit-based Destinations.

#### SwiftUI

* `ViewDestination` can be used to represent most`View`s in your SwiftUI apps.
* `NavigationViewDestination` can be used as a Destination for a `View` which contains a `NavigationStack`. For the associated `View`, conform to the `NavigatingDestinationInterfacing` protocol and assign a `DestinationNavigator` to a `navigator` State property, which will handle `navigationPath` updates.
```swift
@State public var navigator: any DestinationPathNavigating = DestinationNavigator()

NavigationStack(path: $navigator.navigationPath, root: {
...
}
```
* `TabViewDestination` can be used as a Destination for a `View` which contains a `TabView`.
For the associated `View`, conform to the `TabBarViewDestinationInterfacing` protocol, bind the `TabViewDestination`'s `selectedTab` property to the `TabView`'s `selection` parameter, and use its `activeTabs` property to create the tabs. This is an array of `TabModel` objects which contains a `type` property you supply and can use to configure the tabs.
```swift
TabView(selection: $destinationState.destination.selectedTab) {
    ForEach($destinationState.destination.activeTabs, id: \.self) { tab in
        buildView(for: tab.wrappedValue)
        .tag(tab.wrappedValue.type.tabName)
        .tabItem {
        	Label(tab.wrappedValue.type.tabName, systemImage: tab.wrappedValue.type.imageName)
        }
    }
}
```

##### ViewModifiers
* `BackNavigationModifier` adds a custom back button for `View`s which hold `NavigationStack`s, used in conjunction with a `NavigatingViewDestinationable`-conforming Destination and its `NavigatingDestinationInterfacing`-conforming `View`. 
```swift
// Used when building a navigation View in a ViewBuilder. Creates a BackNavigationModifier.
.goBackButton {
	// this is a NavigatingDestinationInterfacing method which requests the navigator to move to the previous Destination in the path.
	backToPreviousDestination(currentDestination: destinationToBuild)
}
```
 
* `DestinationDisappearModifier` handles the removal of a Destination from the Destinations ecosystem when its associated `View` disappears from a `NavigationStack`.
```swift
// Used when building a navigation View in a ViewBuilder. Creates a DestinationDisappearModifier.
.onDestinationDisappear(destination: destinationToBuild, navigationDestination: destination())
```

* `SheetPresenter` manages the presentation of SwiftUI sheets. Used in conjunction with `SheetPresentation`, this `ViewModifier` automatically enables the presentations of Destinations in sheets which are presented from the Destination this modifier is applied to.
```swift
@State var sheetPresentation = SheetPresentation()

// Used on the View's body. Creates a SheetPresenter ViewModifier.
.destinationSheet(presentation: sheetPresentation)
```

### State Model

A state model is an object that conforms to the `StateModeling` protocol and houses the business logic and view state for a Destination. Where a Destination acts as a coordinator – routing events and managing presentation – the state model owns the data of the user interface, the business logic, and the requests and responses of Interactors. This separation keeps the Destination free of feature-specific logic, allows the state model to be swapped out for testing mocks or A/B variants, and gives the View a single observable object to bind properties to.

A state model is held within the user interface's `DestinationStateable` object and is associated with a single Destination type through its `Destination` associated type, which determines its `EventType`, `InteractorType`, and `ContentType`. A typical state model looks like this:
```swift
@Observable
final class NotesState: StateModeling {

    typealias Destination = NotesView.Destination
    typealias EventType = NotesView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var items: [NoteModel] = []
    var selectedItem: NoteModel.ID?

    init(destination: Destination? = nil) {
       self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType?) {

        switch type {
            case .retrieveNotes:
                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                })
        }
    }

    func handleAsyncInteractorResult<Request>(result: Result<Request.ResultData, any Error>, for request: Request) async where Request : InteractorRequestConfiguring {

        switch result {
            case .success(let content):
                if case .colors(models: let models) = content as? AppContentType {
                    items = models
                }

            case .failure(let error):
                break
        }
    }

}
```

Most of the lifecycle and event handling methods on `Destinationable` have matching methods on `StateModeling`. When the Destination receives one of these calls, its default implementation forwards the call on to the state model. You can implement any of the following on your state class as needed:

* `handleEvent(_:content:)` – Called when the interface calls the same-named event through the Destination's `handleEvent(_:content:)` method. Typically your state model should switch on the event type and either handle it internally or call back to the Destination's `performAction(for:content:)` to trigger the configured presentation or Interactor action.
* `handleInteractorResult(result:for:)` and `handleAsyncInteractorResult(result:for:)` – Called when an Interactor returns a response a request in the form of a Result. If the request was successful, you can cast the `ResultData` of the content model to the ContentType you are expecting and update the state accordingly.
* `prepareForPresentation()` – Called once when the Destination is first presented by a Flow, before its UI is built. Use this for initial state setup that should only run once.
* `prepareForAppearance(isVisible: Bool)` – Called each time the Destination's UI is about to become active. The `isVisible` parameter indicates whether this Destination will actually be on-screen, which is useful for skipping setup work in the middle of a deep-link path presentation.
* `prepareForDisappearance(wasVisible: Bool)` – Called each time the Destination's UI is about to become inactive. Use this for teardown tasks.
* `configureInteractor(_:type:)` – Called automatically when an Interactor is assigned to the Destination. This is a good place to make any initial requests needed to setup the Interactor.
* `cleanupResources()` – Called when the Destination is about to be removed from the Flow. Use this to stop in-progress Interactor tasks and release resources.

The state model should be created by the Destination's Provider when its `buildDestination` method is called by the Flow. The View holds the state model in a `DestinationStateable`-conforming object. Destinations provides a generic `DestinationInterfaceState` class if your user interface needs no specific state model, however in general you will want to have a custom object for each interface in your app. This interface object is also a good place to put your `EventTypeable` and `InteractorTypeable` enum types to define the events and interactors associated with the Destination.
```swift
@Observable
final class NotesInterfaceState: DestinationStateable {

    @AutoCaseIterable
    enum Events: EventTypeable {

        case retrieveNotes

        var rawValue: String {
            switch self {
                case .retrieveNotes:
                    return "retrieveNotes"
            }
        }

        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }

    }

    enum InteractorType: InteractorTypeable {
        case notes
    }

    typealias Destination = NavigationViewDestination<Events, NotesView, Routes, AppContentType, AppTabType, InteractorType>

    var destination: Destination
    var stateModel: NotesState

    init(destination: Destination, state: NotesState) {
        self.destination = destination
        self.stateModel = state
        self.destination.stateModel = state
    }
}
```

The user interface can access the state model through this interface state object, observing properties for updates:
```swift
struct NotesView: NavigatingDestinationInterfacing {
    <....>
    @State var destinationState: NotesInterfaceState
    
    init(destination: Destination, state: NotesState) {
        self.destinationState = NotesInterfaceState(destination: destination, state: state)
    }
    
    var body: some View {
        NavigationStack(path: $destinationState.navigator.navigationPath, root: {
            List(destinationState.stateModel.items, selection: $destinationState.stateModel.selectedItem) { note in
                NotesRow(item: note)
            }
        }
        <....>
    }
}
```

### DestinationPresentation

 `DestinationPresentation` is a model used to configure how a Destination is presented or removed. It contains information such as the type of Destination to present, the type of presentation to be made, and the type of content to pass along. They are typically associated with a particular `InterfaceAction` and used to trigger a new presentation when a user interaction is made with the current UI.
 
Destinations has several built-in presentation types which `DestinationPresentation` supports to enable native SwiftUI and UIKit UI navigation, as well as more complex or custom behavior.

* `navigationStack(type: NavigationPresentationType)` This presentation type will add and present a Destination in a navigation stack such as a `UINavigationController` or SwiftUI's `NavigationStack`.
* `tabBar(tab: TabType)` This presentation type will present a Destination in the specified tab of a tab bar component, such as a `UITabBarController` or SwiftUI's `TabView`. If no `destinationType` is present in the `DestinationPresentation` model, the specified tab will simply be selected, becoming the active tab within the interface.
* `splitView(column: SplitViewColumn)` This presentation type will present a Destination in a column of a split view interface, such as a `UISplitViewController` or SwiftUI's `NavigationSplitView`. The `column` parameter defines the column of the split view to present the Destination in.
* `addToCurrent` This presentation type adds a Destination as a child of the currently-presented Destination. Note that this type only works with UIKit and utilizes `UIViewController`'s `addChild` method.
* `replaceCurrent` This presentation type replaces the currently-presented Destination with a new Destination in system UI components which allow that.
* `replaceRoot` This presentation type removes all active Destinations in the Flow and sets a new root Destination. This is useful in use cases such as a user signing out, where you need to remove all the current UI and present a new screen.
* `moveToNearest` This presentation type finds the nearest Destination of the specified type in the view hierarchy and makes it the current Destination, starting from the current Destination and moving upwards in the hierarchy. Typically this presentation type would be used to move to another Destination's user interface higher in a navigation stack. The target Destination type is specified via the `destinationType` property of the associated ``DestinationPresentation`` model and is required.
* `sheet(type: SheetPresentationType, options: SheetPresentationOptions?)` This presentation type presents (or dismisses) a Destination in a sheet. The `options` parameter allows you to customize how the sheet is presented, configuring SwiftUI-specific options with a `ViewSheetPresentationOptions` model and UIKit-specific options with a `ControllerSheetPresentationOptions` model.
* `destinationPath(path: [DestinationPresentation])` This presentation type presents a path of multiple Destination objects, useful for providing deep linking functionality or building complex state with one user interaction. Note that the `destinationPath` presentation type will automatically disable the navigation stack presentation animations of all of its Destination presentations to better support deep linking use cases. This default behavior can be overriden by adding a `NavigationStackPresentationOptions` model with its `shouldAnimate` property set to true for each `DestinationPresentation` you want to change.
* `custom(presentation: CustomPresentation<DestinationPresentation>)` This presentation type enables you to present a custom presentation of a Destination. It can be used to support the presentation of custom UI, as well as system components which Destinations does not directly support. The `presentation` parameter allows you to use a `CustomPresentation` model with specialized closures to provide whatever functionality you need.

### Interactor

 The concept of Interactors comes from [Clean Swift](https://clean-swift.com), used in its architecture as a way to move logic and datasource management out of view controllers. In Destinations, the `Interactable` protocol represents Interactor objects which provide an interface to perform some logic or data request, typically by interfacing with an backend API, handling system APIs, or some other self-contained work. `Datasourceable` inherits from this protocol and should be used for objects which specifically represent a datasource of some kind. There are also Actor-based async versions of these protocols available. 
 
Though requests to Interactors can be made using a Destination's `performRequest` method, in general one should use the `performAction` method. This abstracts the specific implementation details of an interactor away from the interface and lets it focus on making requests through a standardized request.

The recommended way is to assign an event type to your request and using an `InteractorAssisting`-conforming assistant to configure the request, leaving the Destination's interface free of associated business logic.

 Interactors are typically created by Destination providers and stored in the Destination. Like with presentations of new Destinations, Interactor requests are associated with a particular `InterfaceAction` object and are represented by an `InteractorConfiguration` model object. Action types for each Interactor are defined as enums, keeping Interactor-specific knowledge out of the interface. 

For example, here we're creating an Interactor action for making a pagination request to the ColorsDatasource, and then assign it to a `moreButton` event type.
```swift
let paginateAction = InteractorConfiguration<NotesProvider.InteractorType, ColorsDatasource>(interactorType: .notes, actionType: .paginate, assistantType: .basicAsync)
let colorsProvider = NotesProvider(interactorsData: [.moreButton: paginateAction])
```
 As with interface presentation events, Interactor requests are typically made by having the state model call the `performAction(for:content:)` method on the state model's Destination and sending the event type associated with the interactor request. However, you're also free to retrieve the interactor by calling `interactor(for:)` on the Destination, and then calling `perform(request:)` on it directly. That can be helpful when you need to chain async requests or throw them into an Task Group.

#### Interactor assistants

Interactor assistants are conduits between a Destination and its Interactors. They create the actual Request model to be passed to the Interactor based on the interface action type passed to it, and for async assistants they also pass on the result of the Interactor's operation to the Destination. They are defined when creating an `InteractorConfiguration` and there are three types: `basic`, `basicAsync`, and `custom(assistant:)`. The first two are built-in, basic assistants to be used with synchronous and async Interactors respectively. If you don't need to pass any state with an Interactor request, these assistants are all you need. Otherwise you will need to create a custom assistant, conforming to either `InteractorAssisting` to assist `Interactable` Interactors, or `AsyncInteractorAssisting` to assist `AsyncInteractable` Interactors.

Destination classes make requests of an Interactor assistant through the `handleAsyncRequest(destination:, content:)` method, for assistants conforming to `AsyncInteractorAssisting`, and the `handleRequest(destination:, content:)` method for assistants conforming to `InteractorAssisting`. Custom assistants should create a Request object with the provided action type and any other configuration state, call `performRequest(...)` on the Destination, and then pass back the result to the Destination. You might also want to use a custom assistant to handle an Interactor which returns an ongoing sequence of values, for instance listening to Core Location updates or consuming updates from a real-time server subscription. You can see an example of this with the Counter tab in the SwiftUI basic example project, which consumes values from an AsyncStream.

Here's an example implementation of `handleAsyncRequest()` where we're requesting the Interactor add a Note. The Note model is passed via the `content` parameter and then added to the action type, being then passed in with the NoteRequest to the Interactor. After the operation is complete, the result is passed back and sent on to the Destination via the `handleInteractorResult()` method.
```swift
func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {
    
    switch actionType {
        case .add:

            switch content {
                case .note(model: let note):
                    let request = NoteRequest(action: .add(note: note))
                    let result = await destination.performRequest(interactor: interactorType, request: request)
                    await destination.handleInteractorResult(result: result, for: request)
                default:
                    break
            }
    }
}
```

#### Handling an Interactor result

We've shown how to connect an Interactor action to an event request, but how do we handle the result of the operation?  

For an Interactor that conforms to `AsyncInteractable`, the result is passed back to the Destination through `handleAsyncInteractorResult()` from your Interactor assistant. The Destination's default implementation forwards the result on to its state model, so the most natural place to implement this method is on your state class. As a state model can be associated with a Destination that houses multiple Interactors, you'll need to cast the content to the `ResultData` type of the Request inside this method.
```swift
// In a state model
func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async {
    
    switch result {
        case .success(let content):
            switch content as? NotesRequest.ResultData {
                case .notes(models: let notes):
                    self.items = notes
                default: break
            }
            
        case .failure(let error):
            destination?.logError(error: error)
    }
}
```

### Provider

A Provider is responsible for building a specific type of Destination class. There are two dictionaries, `presentationsData` and `interactorsData`, which pair configuration objects with event types and are used to configure a Destination with the presentations and interactor actions it supports. When a Flow needs to present a new Destination, it finds the Provider associated with the requested Destination type and calls the `buildDestination(...)` method. This method should create the state model, the Destination, and the `View` or `UIViewController`, wire them together, and then create any Interactors and add them to the Destination.

Here's a simple example that creates a NotesDestination and its associated `View`, assigns a a state model to the View, and a datasource to the Destination that will supply Note models to the UI, and then returns the Destination to the Flow object for presentation. The Destination's `stateModel` reference is set up automatically by `assignAssociatedView`.
```swift
public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, Destination.DestinationType, Destination.ContentType, Destination.TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
    
    let destination = NotesDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

    let state = NotesState()
    let view = NotesView(destination: destination, state: state)
    destination.assignAssociatedView(view: view)

    let datasource = NotesDatasource()
    destination.assignInteractor(interactor: datasource, for: .notes)
            
    return destination
    
}
```

### Next Steps

Now that you've had an overview of the major concepts in Destinations, please check out the [Examples projects](../Examples/) to see Destinations in action in UIKit and SwiftUI, or dive deep into the source [Documentation](https://poetmountain.github.io/Destinations/).
