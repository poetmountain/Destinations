#### 1.0.1
Added the ability to disable animations when presenting a Destination in a navigation stack, either for SwiftUI's `NavigationStack` or UIKit's `UINavigationController`. You can add navigation presentation options on a per-Destination basis by setting a `NavigationStackPresentationOptions` model on a `DestinationPresentation`'s `navigationStackOptions` property. 

Note that the `destinationPath` presentation type will automatically disable the navigation stack presentation animations of all of its Destination presentations to better support deep linking use cases. This default behavior can be overriden by adding a `NavigationStackPresentationOptions` model with its `shouldAnimate` property set to true for each `DestinationPresentation` you want to change.

#### 1.0.0
Initial release