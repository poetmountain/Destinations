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
