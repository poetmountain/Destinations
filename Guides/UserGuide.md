## Overview

Let's take a deeper look at how you can use Destinations to power your app to reduce implementation time and free up your user interfaces to focus on surprising and delighting your users.

### Setup

To configure your app, `DestinationPresentation` objects should be created to define every Destination presentation a user can initiate. There's a few main properties to configure. 

* The `destinationType` property represents the type of Destination to be presented. This should be a value of an enum type of your choosing. Multiple presentations may use the same type. For instance, you could have a `.userProfile` type that is represented in two different `DestinationPresentation`s – presented in your app both in a Profile tab and also appearing in a sheet. This property is optional, but if you intend to display a new Destination then you'll need to define one.
* The `presentationType` property denotes how a Destination's interface should be presented in the UI, such as in a navigation stack or a sheet. Several types are available that represent system navigation type as well as custom behaviors. More information on each type is available in the [DestinationPresentation](#destinationpresentation) section.
* The `contentType` property allows you to pass in a content model to supply configuration data or initial data for the Destination's interface.
* The `assistantType` property allows you to define an assistant which provides additional configuration when the Destination is being presented. In most cases you can just use the `.basic` assistant which Destinations implements internally. However, if you need to pass content from an interface or are using custom UI that needs special handling then you'll need to use the `.custom(assistant: any InterfaceActionConfiguring)` type and provide your own assisant.

For Interactors, use `InteractorConfiguration` objects to define actions which can be requested from UI interactions.
* The `interactorType` property defines the type of Interactor to request an action from. This is an enum type of your choosing and can be scoped to a particular Destination. In other words, each Destination can have its own set of interactor types, and the association between a specific Interactor and an interactor type is made when calling the `setupInteractor(interactor: type:)` method on a Destination.
* The `actionType` property defines the specific action of the interactor to be requested, represented by an enum type of your choosing and is scoped to individual Interactors.

These `DestinationPresentation`s and `InteractorConfiguration`s are then supplied to their associated Destination providers – Destinations that should be presented and Interactor actions that should be requested from user interactions tied to a specific Destination:
```swift
let presentColorDetail = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .colorDetail, presentationType: .tabBar(tab: .colors), assistantType: .custom(ChooseColorFromListAssistant()))
let moreColorsRequest = InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colorsDatasource, actionType: .paginate)

let colorsListProvider = ColorsListProvider(presentationsData: [.selectColor: presentColorDetail], interactorsData: [.moreButton: moreColorsRequest])
```

### Interaction Flow

**User interaction → Destination → InterfaceAction → Interaction Assistant → Flow → new Destination**

One of the main responsibilities of Destinations is to handle the presentation of new Destinations, typically triggered from a user interacting with a UI element. These user interactions are represented by `UserInteractionTypeable`-conforming enum types which are scoped to an individual Destination. Not every UI element on a particular Destination's interface must be represented by a user interaction type, but if a user interaction should trigger a presentation or an Interactor request should. 

When a user interacts with one of these element types, you should call the `performInterfaceAction(interactionType: content:)` method on the Destination, passing in the user interaction type and an optional content model.  Note that `performInterfaceAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.
```swift
destination().handleThrowable {
    try destination().performInterfaceAction(interactionType: .moreButton)
}
```

Calling `performInterfaceAction()` instructs a Destination to choose the appropriate presentation assistant, configure an `InterfaceAction` object, and then run the action. `InterfaceAction`s represent the action that is attached to a specific `UserInteractionTypeable` enum type. The `InterfaceAction` model contains data used to configure this action, and if the action represents a presentation it is first configured by the associated assistant from the `DestinationPresentation`'s `assistantType` property before the action is run. That assistant is defined when you create a `DestinationPresentation` object during app setup.

When the `InterfaceAction` is run, the `Flow` uses the `DestinationPresentation` object to find an existing Destination that it references, or if one is not found, builds a new one using a Destination provider assigned to its type. The Destination is then set up by the `DestinationPresentation` and its interface is presented using the presentation type assigned to the `DestinationPresentation`'s `presentationType` property.

### Destination

A Destination represents a unique area in an app which can be navigated to by the user. In SwiftUI this is typically a fullscreen `View` object, and in UIKit it's a `UIViewController` class or subclass, but it can also contain a group of Destination objects such as a `UITabBarController` or a carousel. A Destination holds references to the UI element it's associated with, but it doesn't handle the particulars of laying out elements on the screen. Instead, the role of Destination objects in the ecosystem is to send and receive messages and datasource requests on behalf of their UI, such as passing on a message to trigger an action when a user taps a button.

 In most cases you should be able to use the provided `ViewDestination` or `ControllerDestination` classes for SwiftUI or UIKit apps respectively. They are customized to a particular Destination through generic arguments.  To handle presentation requests that require specialized configuration or need to handle content models, you can create custom assistants which conform to the `InterfaceActionConfiguring` protocol. To handle requests to an interactor, you can create assistants which conform to the `InteractorAssisting` protocol. There are more specific classes to support interfaces like Tab Bars, but you can also use your own Destination classes by conforming to `ViewDestinationable` or `ControllerDestinationable` if you should need custom functionality or just want to avoid using generics.

 There is a two-way connection between a Destination and its interface which is handled by a `DestinationStateable`-conforming object. Destinations comes with a `DestinationInterfaceState` object which can be used for this purpose, though you can create your own class if you'd like to store other state in it. When a Destination is removed from the ecosystem, cleanup is done internally to ensure no retain cycles occur.

 The state object must be stored on the interface and should be created in the initialization method, passing in its Destination object.
```swift
@State var destinationState: DestinationInterfaceState<Destination>

init(destination: Destination, model: ColorViewModel? = nil) {
    self.destinationState = DestinationInterfaceState(destination: destination)
}
```

You can access the Destination instance through this state object, but you can also use the shortcut method `destination()`.

#### UIKit

* `ControllerDestination` can be used to represent most `UIViewController`s in your app which don't need to handle interactor requests. 
* `NavigationControllerDestination` can be used as a Destination for a `UINavigationController` class. 
* `TabBarControllerDestination` can be used as a Destination for a `UITabBarController` class. `UINavigationController`s are automatically created for each tab, so new presentations targeting a tab just work.  In the associated `UITabBarController` class which conforms to the `TabBarControllerDestinationInterfacing` protocol, you should implement the `customizeTabItem(tab: navigationController:)`. This method passes a`TabModel` object which contains a `type` property you supply and can use to configure the tabs.
* `SwiftUIContainerDestination` can be used as a Destination for a `SwiftUIContainerController`, which allows you to host SwiftUI content within UIKit via `UIHostingController` instance. The SwiftUI content is managed by a separate `ViewFlow` contained within the `SwiftUIContainerDestination`, and Destination presentation requests for new `View`s can even be sent from UIKit-based Destinations.

#### SwiftUI

* `ViewDestination` can be used to represent most `View`s in your SwiftUI app which don't need to handle datasource state.
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

### DestinationPresentation

 `DestinationPresentation` is a model used to configure how a Destination is presented or removed. It contains information such as the type of Destination to present, the type of presentation to be made, and the type of content to pass along. They are typically associated with a particular `InterfaceAction` and used to trigger a new presentation when a user interaction is made with the current UI.
 
Destinations has several built-in presentation types which `DestinationPresentation` supports to enable native SwiftUI and UIKit UI navigation, as well as more complex or custom behavior.

* `navigationStack(type: NavigationPresentationType)` This presentation type will add and present a Destination in a navigation stack such as a `UINavigationController` or SwiftUI's `NavigationStack`.
* `tabBar(tab: TabType)` This presentation type will present a Destination in the specified tab of a tab bar component, such as a `UITabBarController` or SwiftUI's `TabView`. If no `destinationType` is present in the `DestinationPresentation` model, the specified tab will simply be selected, becoming the active tab within the interface.
* `splitView(column: SplitViewColumn)` This presentation type will present a Destination in a column of a split view interface, such as a `UISplitViewController` or SwiftUI's `NavigationSplitView`. The `column` parameter defines the column of the split view to present the Destination in.
* `addToCurrent` This presentation type adds a Destination as a child of the currently-presented Destination. Note that this type only works with UIKit and utilizes `UIViewController`'s `addChild` method.
* `replaceCurrent` This presentation type replaces the currently-presented Destination with a new Destination in system UI components which allow that.
* `sheet(type: SheetPresentationType, options: SheetPresentationOptions?)` This presentation type presents (or dismisses) a Destination in a sheet. The `options` parameter allows you to customize how the sheet is presented, configuring SwiftUI-specific options with a `ViewSheetPresentationOptions` model and UIKit-specific options with a `ControllerSheetPresentationOptions` model.
* `destinationPath(path: [DestinationPresentation])` This presentation type presents a path of multiple Destination objects, useful for providing deep linking functionality or building complex state with one user interaction.

  Note that the `destinationPath` presentation type will automatically disable the navigation stack presentation animations of all of its Destination presentations to better support deep linking use cases. This default behavior can be overriden by adding a `NavigationStackPresentationOptions` model with its `shouldAnimate` property set to true for each `DestinationPresentation` you want to change.
  
* `custom(presentation: CustomPresentation<DestinationPresentation>)` This presentation type enables you to present a custom presentation of a Destination. It can be used to support the presentation of custom UI, as well as system components which Destinations does not directly support. The `presentation` parameter allows you to use a `CustomPresentation` model with specialized closures to provide whatever functionality you need.

### Interactor

 The concept of Interactors comes from [Clean Swift](https://clean-swift.com), used in its architecture as a way to move logic and datasource management out of view controllers. In Destinations, the `Interactable` protocol represents Interactor objects which provide an interface to perform some logic or data request, typically by interfacing with an backend API, handling system APIs, or some other self-contained work. `Datasourceable` inherits from this protocol and should be used for objects which specifically represent a datasource of some kind. There are also Actor-based async versions of these protocols available. 
 
Though requests to Interactors can be made using a Destination's `performRequest` method, in general one should use the `performInterfaceAction` method. This abstracts the specific implementation details of an interactor away from the interface and lets it focus on making requests through a standardized request.

The recommended way is to assign a user interaction type to your request and using an `InteractorAssisting`-conforming assistant to configure the request, leaving the Destination's interface free of associated business logic.

 Interactors are typically created by Destination providers and stored in the Destination. Like with presentations of new Destinations, Interactor requests are associated with a particular `InterfaceAction` object and are represented by an `InteractorConfiguration` model object. Action types for each Interactor are defined as enums, keeping Interactor-specific knowledge out of the interface. 

For example, here we're creating an Interactor action for making a pagination request to the ColorsDatasource, and then assign it to a `moreButton` user interaction type:
```swift
let paginateAction = InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate, assistantType: .basic)
let colorsProvider = ColorsProvider(interactorsData: [.moreButton: paginateAction])
```

And here is that user interaction type being called by a Destination's interface. Note that `performInterfaceAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.
```swift
destination().handleThrowable {
    try destination().performInterfaceAction(interactionType: .moreButton)
}
```

#### Interactor assistants

Interactor assistants are conduits between a Destination and its Interactors. They create the actual Request model to be passed to the Interactor based on the interface action type passed to it, and for async assistants they also pass on the result of the Interactor's operation to the Destination. They are defined when creating an `InteractorConfiguration` and there are three types: `basic`, `basicAsync`, and `custom(assistant:)`. The first two are built-in, basic assistants to be used with synchronous and async Interactors respectively. If you don't need to pass any state with an Interactor request, these assistants are all you need. Otherwise you will need to create a custom assistant, conforming to either `InteractorAssisting` to assist `Interactable` Interactors, or `AsyncInteractorAssisting` to assist `AsyncInteractable` Interactors.

Destination classes make requests of an Interactor assistant through the `handleAsyncRequest(destination:, content:)` method, for assistants conforming to `AsyncInteractorAssisting`, and the `handleRequest(destination:, content:)` method for assistants conforming to `InteractorAssisting`. Custom assistants should create a Request object with the provided action type and any other configuration state, call `performRequest(...)` on the Destination, and then pass back the result to the Destination. You might also want to use a custom assistant to handle an Interactor which returns an ongoing sequence of values, for instance listening to Core Location updates or consuming updates from a real-time server subscription. You can see an example of this with the Counter tab in the SwiftUI basic example project, which consumes values from an AsyncStream.

Here's an example implementation of `handleAsyncRequest()` where we're requesting the Interactor add a Note. The Note model is passed via the `content` parameter and then added to the action type, being then passed in with the NoteRequest to the Interactor. After the operation is complete, the result is passed back and sent on to the Destination via the `handleInteractorResult()` method.
```swift
func handleAsyncRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) async where Destination.InteractorType == InteractorType {
    
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

We've shown how to connect an Interactor action to a user interaction request, but how do we handle the result of the operation?  

For an Interactor that conforms to `AsyncInteractable` or `AsyncDatasourceable`, the result can be presented to the calling Destination's `handleAsyncInteractorResult()` method from your custom Interactor assistant. As a Destination can house multiple Interactors which provide results via this method, we have to cast the content to the ResultData type of the Request inside this method.
```swift
func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) {
    
    switch result {
        case .success(let content):
            switch content as? NotesRequest.ResultData {
                case .notes(models: let notes):
                    self.items = notes
                default: break
            }
            
        case .failure(let error):
            logError(error: error)
    }
}
```

How you update your UI with the results of an Interactor request is up to you and the requirements of the app. For instance, the `items` array we assigned the result to in the previous example could be an observable property that the Destination's SwiftUI `View` uses to populate a `List` of Notes:
```swift
List(destination().items, selection: $selectedItem) { note in
    NotesRow(item: note)
}
```

If an Interactor conforms to `Interactable` or `Datasourceable` you can call the Destination's `handleInteractorResult()` method with the result of the request. Alternately, you can assign a `InteractorResponseClosure` closure to the Interactor with its `assignResponseForAction(...)` method when you create the Interactor in a Provider within the `buildDestination(...)` method:
```swift
let colorsResponse: InteractorResponseClosure<ColorsRequest> = { [weak destination] (result: Result<ColorsRequest.ResultData, Error>, request: ColorsRequest) in
    switch result {
        case .success(let data):
            ...
        case .failure(let error):
            ...
    }
}

let datasource = ColorsDatasource(with: ColorsPresenter())
datasource.assignResponseForAction(response: colorsResponse, for: .paginate)
```

### Provider

A Provider is responsible for building a specific type of Destination class. There are two dictionaries, `presentationsData` and `interactorsData`, which pair configuration objects with user interaction types and are used to configure a Destination with the presentations and interactor actions it supports. When a Flow needs to present a new Destination, it finds the Provider associated with the requested Destination type and calls the `buildDestination(...)` method. This method should create the Destination, create the `View` or `UIViewController` and assign it to the Destination, and then create any Interactors and add them to the Destination.

Here's a simple example that creates a NotesDestination and its associated `View`, assigns a datasource to the Destination that will supply Note models to the UI, and returns the Destination to the Flow object for presentation.
```swift
public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {
    
    let destination = NotesDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

    let view = NotesView(destination: destination)
    destination.assignAssociatedView(view: view)

    let datasource = NotesDatasource()
    destination.setupInteractor(interactor: datasource, for: .notes)
            
    return destination
    
}
```

### Flow

 Flows manage the creation, appearance, and removal of Destinations as a user navigates through the app. They are the single source of truth for what Destinations currently exist in the ecosystem. Typically you don't interact with them directly after they've been configured. In most cases you can use one of the provided `ViewFlow` or `ControllerFlow` classes for SwiftUI and UIKit apps respectively.

When creating a Flow object you supply it with a starting Destination. All Destination user interfaces which are presented will be attached from this base. In the UI where you want to attach the Flow to (generally you want to do so at the root of your app's UI hierarchy), you can call `startingDestinationView()` on a `ViewFlow` (for SwiftUI apps) or `assignRoot(rootController: <some UIController>)` on a `ControllerFlow` (for UIKit apps) to attach the Flow's UI hierarchy to the app's interface.

This SwiftUI app sketch shows how simple it is to add a Flow object. Just assign to the Flow object the Providers for the Destination types you want to support, as well as providing the starting Destination, and then attach the Flow's interface root to the app's UI. Please see the example projects for full implementations.
```swift
typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>

@State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?
@State var hasStartedAppFlow = false

func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {
        ...
        
    let startingTabs: [TabType] = [.home, .userNotes]
    let startingType: DestinationType = .tabBar(tabs: startingTabs)
    let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
    
    let homeProvider = HomeProvider()
    let notesProvider = NotesProvider()
    let tabsProvider = TabsProvider()
    let providers: [DestinationType: any ViewDestinationProviding] = [.home: homeProvider, .notes: notesProvider, .tabBar: tabsProvider]
    
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

### Next Steps

Now that you've had an overview of the major concepts in Destinations, please check out the [Examples projects](Examples) projects to see Destinations in action in UIKit and SwiftUI, or dive deep into the source [Documentation](https://poetmountain.github.io/Destinations/).
