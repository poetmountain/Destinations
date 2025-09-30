### 2.2.4
* Added ability to turn off the iOS 26 Liquid Glass background in BackNavigationModifier's back button.

### 2.2.3
* Fixes for `replaceRoot` with `destinationPath` presentation types in SwiftUI and UIKit objects.
* Fixed `NavigatingViewDestinationable`'s `replaceChild` not being called for `replaceCurrent` presentations.

### 2.2.2
* Action assistants can now modify a presentation's presentation type by setting the `presentationType` property of an `InterfaceAction`'s `InterfaceActionData` object. One way to do this would be to pass in a presentation type via the `content` property of the `performInterfaceAction` method and assign that in the assistant. This change allows more runtime dynamic control of how Destinations are presented from user interactions, such as dynamically creating a path of multiple Destination presentations at runtime.
* Presentations using the `destinationPath` presentation type to present multiple Views in a NavigationStack now animate by default in order to fix the NavigationStack sometimes not presenting all of the Views.

### 2.2.1
* Action assistants can now modify a presentation's destination type by setting the `destinationType` property of an `InterfaceAction`'s `InterfaceActionData` object. One way to do this would be to pass in a Destination type via the `content` property of the `performInterfaceAction` method and assign that in the assistant. This change allows more runtime dynamic control of which Destinations are presented from user interactions.

### 2.2.0
#### Features
* Added a `replaceRoot` presentation type. This type removes all active Destinations in the Flow and sets a new root Destination. This is useful in use cases such as a user signing out, where you need to remove all the current UI and present a new screen.
* Added a `cleanupResources()` method to `AbstractInteractable` which is called when an Interactor's Destination is about to be removed from the Flow. You can implement this method in your Interactors to remove any resource references and stop any in-progress tasks.
#### Fixes
* Fixes to address Xcode 26 concurrency warnings
* `AsyncInteractable` now conforms to the `ResultData` type from its Request
* Fixed `DefaultAsyncInteractorAssistant` not calling `handleAsyncInteractorResult`; it was previously calling the non-asynchronous method version.
* Fixed `replaceCurrent` presentation type not replacing single Views (`replaceCurrent` was not working when there was a single active Destination in a `ViewFlow`)
* Updated example projects and tests
#### Changes
* The `assignRoot(rootController:)` method on `ControllerFlowable` is deprecated and will be removed in a future version. Please use the new `assignBaseController(_:)` method instead.

### 2.1.0
* Fixes for Swift 6.1 compiler issues with generics and associated type complexity.

#### 2.0.0
* Interactors now support a separate type for passing in request state.
* Interactor assistants are no longer tightly coupled to a Destination, allowing assistants to be reused with multiple Destination types with no changes.
* Default interactor assistants have been added for simple use cases where state does not need to be sent with requests. `InteractorConfiguration` has been updated to accept a new `assistantType`, and these default assistants are represented by the types `basic` and `basicAsync`, for synchronous and async assistants respectively. If you need a custom assistant, use the `custom(assistant:)` type instead.
* Interactors now have a new method `prepareForRequests()` which can be called to to configure an Interactor before use. Typically you might want to call this from a Destination's `configureInteractor()` method.
* Most internal state properties on Destination classes have been moved to a new `DestinationInternalState` state object (as well as a secondary `GroupDestinationInternalState` state object for Destination classes conforming to `GroupedDestinationable`). Any existing properties on your Destination classes which duplicate these state objects can be safely removed.
* Destination classes have a new `prepareForPresentation()` method which should be used to initialize any state, datasource retrievals, etc. before the Destination is presented.
* Destination classes have new `handleInteractorResult(result:, for:)` and `handleAsyncInteractorResult(result:, for:)` methods to handle the results of Interactor operations.
* Automated the setup of Interactor assistants and Destination presentations when a Provider builds a Destination. Manually calling `buildPresentations()` and manually setting up Interactor assistants is no longer necessary within the Provider `buildDestination(...)` method.
* Updated the basic SwiftUI example project to include an example of an Interactor that returns a continuous stream of result values using AsyncStream. See the new "Counter" tab in the example app.

#### 1.2.0
* Improved support for SwiftUI content hosted within UIKit controllers using `SwiftUIContainerDestination`. New SwiftUI content can now be presented from a UIKit-based Destination without any knowledge of the SwiftUI navigation stack. Destinations will automatically handle this use case when targeting a `SwiftUIContainerDestination` which contains a `NavigationStack`, when specifying a `DestinationPresentation`'s `presentationType` as a `navigationController()` or `splitView()`.
* Updated tests and example projects. The "SplitViewUIKitExample" project has been updated to showcase this functionality.
* Package.swift has been updated to formalize a Swift 6 requirement.

#### 1.1.0
* Destinations now supports split views: `UISplitViewController` on UIKit and `NavigationSplitView` on SwiftUI. You can present or target them with the new presentation type `splitView(column: SplitViewColumn)`.
Example:
```swift
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail,
                                                       presentationType: .splitView(column: SplitViewColumn(uiKit: .secondary)),
                                                       assistantType: .custom(ChooseColorFromListActionAssistant()))
```
* Moved the `navigator` property out of the `NavigatingDestinationInterfacing` protocol and into a new Destination state type `NavigationDestinationInterfaceState`, in order to reduce setup requirements of `NavigationStack`-containing `View`s. The `navigator` can now be accessed from the `View` through the `destinationState` state object.
* Fixed Flow objects not removing Destinations that are children of `GroupedDestinationable` objects when they are removed internally by the group.
* Renamed `DestinationsOptions` to `DestinationsSupport`.
* Updated tests and example projects.

#### 1.0.2
* Fixed Swift strict concurrency issues
* Fixed `replaceCurrent` presentation type not removing Destinations on UIKit in navigation controllers
* Fixed `ControllerFlow` not properly updating current Destination when presentation switches tabs
* Fixed `replaceCurrent` presentation type for SwiftUI
* Updated Package.swift to use 6.0 swift tools
* Updated tests

#### 1.0.1
Added the ability to disable animations when presenting a Destination in a navigation stack, either for SwiftUI's `NavigationStack` or UIKit's `UINavigationController`. You can add navigation presentation options on a per-Destination basis by setting a `NavigationStackPresentationOptions` model on a `DestinationPresentation`'s `navigationStackOptions` property. 

Note that the `destinationPath` presentation type will automatically disable the navigation stack presentation animations of all of its Destination presentations to better support deep linking use cases. This default behavior can be overridden by adding a `NavigationStackPresentationOptions` model with its `shouldAnimate` property set to true for each `DestinationPresentation` you want to change.

#### 1.0.0
Initial release
