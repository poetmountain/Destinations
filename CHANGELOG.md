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
