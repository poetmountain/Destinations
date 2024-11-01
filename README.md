# Destinations
![Static Badge](https://img.shields.io/badge/Swift-5.10_%7C_6.0-005AA5.svg) ![Static Badge](https://img.shields.io/badge/Platforms-iOS-005AA5.svg) ![License](https://img.shields.io/badge/License-MIT-005AA5.svg "License")

Destinations is a Swift library for UIKit and SwiftUI that is designed to remove application and business logic from your interfaces, manage navigation flow, and abstract datasource interactions so that your user interfaces can focus again on the user. It is based on a philosophy that emphasizes clear separation of concerns, that each significant `View` or `UIViewController` in an app should not know about each other, and that UI and functionality should be able to be easily substituted as your needs change.

* Enables clean separation of concerns between your interfaces, datasources, and other application logic
* Allows you to easily replace UI and datasources for A/B testing or providing testing mocks
* Provides easy deep linking capability
* Provides the ability to display and test sections of your apps in isolation
* A flexible and extensible, protocol-based system to fit your project's needs, including custom UI
* A similar API for both UIKit and SwiftUI, and generic enough to allow further platform support
* Comes with common framework implementations, but extensible enough to provide your own
* Full [documentation](https://poetmountain.github.io/Destinations/)

## Getting Started

#### Get started with the **[user guide](Guides/UserGuide.md)** for detailed explanations and examples.

Also check out the [Examples projects](Examples) to see Destinations in action in UIKit and SwiftUI, or dive deep into the source [Documentation](https://poetmountain.github.io/Destinations/).

## Overview

Keeping application logic, tight couplings to datasources and system APIs, and knowledge of other views out of your views and view controllers can be a constant battle, compounded by often tight timelines to get a feature shipped. Destinations is a library designed from the ground up to address this problem.

Destinations is designed to represent each significant interface element – typically one that would be presented as the active view on the screen – as an abstract object that conforms to the `Destinationable` protocol, but for shorthand I'll refer to as a Destination. A Destination's role in the ecosystem is to represent a discrete user interface screen and to manage user interaction events and Interactor requests on behalf of that interface. And what is an Interactor? Think of it as a black box you can attach to a Destination which handles logic, system APIs, or datasource requests. It could be as simple as a counter or as complex as a cloud syncing service. A Destination doesn't handle any UI directly though; that remains the responsibility of the interface. A Destination allows its interface to focus on that task. And then above the Destination is the Flow object, which as you might expect manages the flow from Destination to Destination as a user navigates through the app, presenting each Destination that is built using a Provider and using configuration models you have defined.

Those configuration models, called `DestinationPresentation`s and `InteractorConfiguration`s, are where things get more interesting. Let's say you're making a UIKit app and create a `DestinationPresentation` which will present a a detail screen in the currently active navigation controller. You would do something like this:
```swift
let detailPresentation = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .detail, presentationType: .navigationController(type: .present))
```

Now we need to feed that into a Provider. Each Provider builds a specific Destination, and those Providers are used by the Flow each time a new Destination needs to be created. So the Provider we're going to use builds the Destination whose interface manages that navigation controller we're presenting the detail screen in. The `presentationsData` dictionary in the example below pairs user interaction types for that Destination with a presentation configuration model. So in this example, we're telling the Destination that when a user taps the `.detailButton` type, the `detailPresentation` action should be run, which will create the detail Destination and present it on-screen by pushing it onto the navigation controller.
```swift
let listProvider = ListProvider(presentationsData: [.detailButton: detailPresentation])
```

 To enable that in your interface, all you need to do is pass that user interaction type to its Destination:
```swift
destination().handleThrowable { [weak self] in
    try self?.destination().performInterfaceAction(interactionType: .detailButton)
}
```

So we've created an interaction where the `UIViewController` housing this button knows nothing about the detail screen or that it should be presented in its navigation controller. All of that presentation code and associated logic is handled by Destinations internally. We've both strengthened the separation of concerns with this controller and also DRY'd up the code. And creating an Interactor action and assigning it to a user interaction is similarly easy.

Because of that pairing between user interaction type and presentation action, we've also opened up the ability to quickly reconfigure how this button functions. Let's say the product team wants to have the button to present a a different view in a modal sheet instead. Modifying that button's behavior is as easy as creating a new `DestinationPresentation` and assigning it to the `.detailButton` type instead. This flexibility makes it possible to quickly test new behaviors, conduct A/B tests, supply mock datasources for testing, and more.

Here's a simple example of an initial Destinations configuration which sets up the initial interfaces for a SwiftUI app that should display a `TabView` with two tabs and their content `View`s. For simplicity's sake we're only defining one user action, a "colorDetail" interaction which displays a detail `View` when a color cell is tapped. In this code we create the starting Destination, create a presentation model to handle a user selecting a color, setup the providers for the Destinations and their associated user interfaces, and finally build a `ViewFlow` which will manage the flow of the app.
```swift
func buildFlow() -> ViewFlow<DestinationType, TabType, ContentType> {

    // set up starting Destination
    let startingTabs: [TabType] = [.colors, .home]
    let startingType: DestinationType = .tabBar(tabs: startingTabs)
    let startingDestination = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: startingType, presentationType: .replaceCurrent)

    // set up a presentation for user selecting a color
    let colorSelection = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .colorDetail, presentationType: .navigationController(type: .present))

    // create the Destination providers
    let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
    let homeProvider = HomeProvider()
    let tabBarProvider = TabBarProvider()

    let providers: [DestinationType: any ViewDestinationProviding] = [
        .colorsList: colorsListProvider,
        .home: homeProvider,
        .tabBar(tabs: startingTabs): tabBarProvider
    ]

    return ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)

}
```

And here we use that `ViewFlow` to display its initial UI within a SwiftUI App file.
```swift
@State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?

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

### Installation

You can add Destinations to an Xcode project by adding it as a Swift package dependency.
```swift
.product(name: "Destinations", package: "Destinations")
```

### License

This library is released under the MIT license. See [LICENSE](LICENSE.md) for details.

I'd love to know if you use Destinations in your projects!