## Overview

Let's take a deeper look at how you can use Destinations to power your app and free up your user interfaces to focus on surprising and delighting your users.

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
let colorSelection = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .colorDetail, presentationType: .tabBar(tab: .colors), assistantType: .custom(ChooseColorFromListAssistant()))
let moreColorsRequest = InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colorsDatasource, actionType: .paginate)

let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection], interactorsData: [.moreButton: moreColorsRequest])
```

### Interaction Flow

**User interaction → Destination → InterfaceAction → Interaction Assistant → Flow → new Destination**

One of the main responsibilities of Destinations is to handle the presentation of new Destinations, typically triggered from a user interacting with a UI element. These user interactions are represented by `UserInteractionTypeable`-conforming enum types which are scoped to an individual Destination. Not every UI element on a particular Destination's interface must be represented by a user interaction type, but if a user interaction should trigger a presentation or an Interactor request should. 

When a user interacts with one of these element types, you should call the `performInterfaceAction
(interactionType: content:)` method on the Destination, passing in the user interaction type and an optional content model.  Note that `performInterfaceAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.
```swift
destination().handleThrowable { [weak self] in
    try self?.destination().performInterfaceAction(interactionType: .moreButton)
}
```

Calling `performInterfaceAction` instructs a Destination to choose the appropriate presentation assistant, configure an `InterfaceAction` object, and then run the action. `InterfaceAction`s represent the action that is attached to a specific `UserInteractionTypeable` enum type. The `InterfaceAction` model contains data used to configure this action, and if the action represents a presentation it is first configured by the associated assistant from the `DestinationPresentation`'s `assistantType` property before the action is run. That assistant is defined when you create a `DestinationPresentation` object during app setup.

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

* `navigationController(type: NavigationPresentationType)` This presentation type will add and present a Destination in a navigation stack such as a `UINavigationController` or SwiftUI's `NavigationStack`.
* `tabBar(tab: TabType)` This presentation type will present a Destination in the specified tab of a tab bar component, such as a `UITabBarController` or SwiftUI's `TabView`. If no `destinationType` is present in the `DestinationPresentation` model, the specified tab will simply be selected, becoming the active tab within the interface.
* `addToCurrent` This presentation type adds a Destination as a child of the currently-presented Destination. Note that this type only works with UIKit and utilizes `UIViewController`'s `addChild` method.
* `replaceCurrent` This presentation type replaces the currently-presented Destination with a new Destination in system UI components which allow that.
* `sheet(type: SheetPresentationType, options: SheetPresentationOptions?)` This presentation type presents (or dismisses) a Destination in a sheet. The `options` parameter allows you to customize how the sheet is presented, configuring SwiftUI-specific options with a `ViewSheetPresentationOptions` model and UIKit-specific options with a `ControllerSheetPresentationOptions` model.
* `destinationPath(path: [DestinationPresentation])` This presentation type presents a path of multiple Destination objects, useful for providing deep linking functionality or building complex state with one user interaction.
* `custom(presentation: CustomPresentation<DestinationPresentation>)` This presentation type enables you to present a custom presentation of a Destination. It can be used to support the presentation of custom UI, as well as system components which Destinations does not directly support. The `presentation` parameter allows you to use a `CustomPresentation` model with specialized closures to provide whatever functionality you need.

### Interactors

 The concept of Interactors comes from [Clean Swift](https://clean-swift.com), used in its architecture as a way to move logic and datasource management out of view controllers. In Destinations, the `Interactable` protocol represents Interactor objects which provide an interface to perform some logic or data request, typically by interfacing with an backend API, handling system APIs, or some other self-contained work. `Datasourceable` inherits from this protocol and should be used for objects which specifically represent a datasource of some kind. There are also Actor-based async versions of these protocols available. 
 
Though requests to Interactors can be made using a Destination's `performRequest` method, in general one should use the `performInterfaceAction` method. This abstracts the specific implementation details of an interactor away from the interface and lets it focus on making requests through a standardized request.

The recommended way is to assign a user interaction type to your request and using an `InteractorAssisting`-conforming assistant to configure the request, leaving the Destination's interface free of associated business logic.

 Interactors are typically created by Destination providers and stored in the Destination. Like with presentations of new Destinations, Interactor requests are associated with a particular `InterfaceAction` object and are represented by an `InteractorConfiguration` model object. Action types for each Interactor are defined as enums, keeping Interactor-specific knowledge out of the interface. 

Here the configuration model for the interface action is being assigned to a "moreButton" user interaction type when the Destination's provider is created:
```swift
let moreButtonConfiguration = InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate)
let colorsListProvider = ColorsListProvider(presentationsData: [.color: colorSelection], 
											  interactorsData: [.moreButton: moreButtonConfiguration])
```

And here is that user interaction type being called a Destination's interface after a user's tap on a UI element. Note that `performInterfaceAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.
```swift
destination().handleThrowable { [weak self] in
    try self?.destination().performInterfaceAction(interactionType: .moreButton)
}
```

 If it's necessary, you can always make a request to a Destination's Interactor directly: 
 ```swift
Task {
    let request = ColorsRequest(action: .paginate, numColorsToRetrieve: 5)

    let result = await destination().performRequest(interactor: .colors, request: request)
    await handleColorsResult(result: result)
}
```

### Flow

 Flows manage the creation, appearance, and removal of Destinations as a user navigates through the app. They are the single source of truth for what Destinations currently exist in the ecosystem. Typically you don't interact with them directly after they've been configured. In most cases you can use one of the provided `ViewFlow` or `ControllerFlow` classes for SwiftUI and UIKit apps respectively.