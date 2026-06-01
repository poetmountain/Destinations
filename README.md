# Destinations
![Static Badge](https://img.shields.io/badge/Swift-6.0%20%7C%206.1%20%7C%206.2%20%7C%206.3-005AA5.svg) ![Static Badge](https://img.shields.io/badge/Platforms-iOS-005AA5.svg) ![License](https://img.shields.io/badge/License-MIT-005AA5.svg "License")

Destinations is a Swift framework for UIKit and SwiftUI apps that is designed to truly decouple your UI and manage navigation flow. It is based on a philosophy that emphasizes clear separation of concerns, that each significant `View` or `UIViewController` in an app should not know about each other, and that UI and functionality should be able to be easily substituted as your needs change. Destinations enables your user interfaces to focus again on the user. It handles app routing, the plumbing between logic and UI, and significantly reduces boilerplate code in your apps.

* Enables clean separation of concerns between your interfaces, datasources, and other application logic
* Allows you to easily replace business logic, datasources, and UI for A/B testing or reusing Views in different contexts
* Reduces development time – provides built-in implementations for many system presentation types, reduces code churn as feature flows change
* Provides easy deep linking capability
* Provides the ability to display and test sections of your apps in isolation
* A flexible and extensible, protocol-based system to fit your project's needs, including custom UI
* A similar API for both UIKit and SwiftUI, and generic enough to allow further platform support. Supports pure UIKit and SwiftUI apps, but also supports hybrid apps with SwiftUI content hosted within UIKit controllers.

## Getting Started

#### Get started with the **[user guide](Guides/UserGuide.md)** for detailed explanations and examples.

Also check out the [Examples projects](Examples) to see Destinations in action in UIKit and SwiftUI, or dive deep into the source [Documentation](https://poetmountain.github.io/Destinations/).

## Overview

Keeping application logic, tight couplings to datasources and system APIs, and knowledge of other views out of your views and view controllers can be a constant battle, compounded by often tight timelines to get a feature shipped. Destinations is a library designed from the ground up to address this problem.

In Destinations, user interfaces have no knowledge of the actions they should take. They have no knowledge of datasources, business logic, or other UI screens, either. These things – View presentations, API requests, logic – are associated with an enum of events which are tied to each Destination. Thus, when a user interacts with a UI element the only thing the View sends along to the Destination is the enum value associated with that event. In this way, app functionality is no longer tightly coupled to UI, and can be switched or modified easily. A button in View A can display View B, even though A has no knowledge of B, or even that it should present a View! A button could make a server request or show a modal sheet simply by switching its associated action, with no direct knowledge of either.

But more than that, abstracting navigation and View presentation actions, along with datasource request handling, enables Destinations to act as a framework for your app's feature flows. And it handles most UIKit and SwiftUI presentation tasks for you, allowing you to focus on your app's functionality instead of writing boilerplate code.

## Presenting a Destination

Destinations represents each significant interface element – typically one that would be presented as the active view on the screen and can be routed to – with an object that conforms to the `Destinationable` protocol. For shorthand I'll refer to these objects as a **Destination**. A Destination's role in the ecosystem is to represent a discrete user interface screen and coordinate on behalf of that interface.

Let's say we have a SwiftUI app which shows user Notes in a `List` in a NotesView `View`, backed by a Destination. We want to create a detail screen that will be pushed onto the `NavigationStack` when a user taps on a Note list item. To do that we should create a `DestinationPresentation` object which represents that action. This object contains the type of Destination to present, the `presentationType` which represents *how* the Destination should be presented, and the `assistantType` which represents the kind of presentation assistant to be used. The `basic` assistant type is usually adequate if you're passing a state model along.
```swift
let notePresentation = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .noteDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
```

In order for the NotesView to be aware of this user action, we need to feed it into a Provider object which builds the NotesDestination and the associated NotesView. The `presentationsData` dictionary in the example below pairs event types for that Destination with a presentation configuration model. Effectively, we're associating a particular type of event with a specific action which Destinations should take.
```swift
let notesProvider = NotesProvider(presentationsData: [.displayNote: notePresentation])
```

Now that we have a defined interface action for presenting the detail `View` and linked it to the `displayNote` event type, we need to connect it to our interface. Assuming we have an `onChange` modifier in the NotesView watching a `selectedItem` property on its state model, we can pass that event type to its Destination along with a `content` parameter providing the selected Note model we should display in the new detail `View`. (We'll cover state models in the next section, but for now just know that they hold a Destination's view state and business logic.)
```swift
.onChange(of: destinationState.stateModel.selectedItem, { [weak stateModel = destinationState.stateModel, weak destination = destination()] oldValue, newValue in
    if let newValue, let item = stateModel?.items.first(where: { $0.id == newValue }) {
        destination?.handleEvent(.displayNote, content: .note(model: item))
    }
})
```

## Making a Datasource Request

Continuing our Notes example, let's hook up an **Interactor** so that we can provide Note models to the list `View`. Interactors house any kind of logic that we want to keep isolated from the UI, such as datasource retrievals, API requests, etc.

So let's start by creating a sketch of a datasource Interactor for our Notes. The `perform(request:) async -> Result<NotesRequest.ResultData, Error>` method here is part of the `AsyncInteractable` protocol and will be called when our Notes Destination makes a request by passing in a NotesRequest. The `action` types we switch on represent the possible actions that the Interactor supports. Once the method retrieves the relevant Note models, it should package them up in a Result and return them.
```swift
actor NotesDatasource: AsyncInteractable {
    typealias Request = NotesRequest
    typealias Item = Request.Item
                
    var items: [Item] = []
    
    func perform(request: Request) async -> Result<NotesRequest.ResultData, Error> {
    
        switch request.action {
            case .retrieve:
                return await retrieveNotes(request: request)
            default: break
        }
    }
}
```

And here is the NotesRequest struct that we passed into the `perform(request:)` method. **Request** objects specify the type of action the Interactor should take, and can contain any necessary configuration state.
```swift
struct NotesRequest: InteractorRequestConfiguring {

    enum ActionType: InteractorRequestActionTypeable {
        case retrieve
        case paginate
    }
    
    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType
    typealias Item = NoteModel
    
    let action: ActionType
}
```

Now that we have a datasource and a way to make requests of it, we need to make an interface action which will represent a specific request. Interactor interface actions are represented by `InteractorConfiguration` models. They specify the type of Interactor being called, the type of action the Interactor should take, and the type of Interactor assistant that should be used. (Interactor assistants create the actual Request and handle communication between the Destination and the Interactor) 

As with our `View` presentation we can pass this action, paired with an event type which should call it, in to the Provider which creates the Notes list `View`. All interactor actions should go into the `interactorsData` dictionary parameter. Here we've assigned the Notes retrieval action to a new event type `retrieveNotes`.
```swift
let notesAction = InteractorConfiguration<NotesDestination.InteractorType, NotesDatasource>(interactorType: .notes, actionType: .retrieve, assistantType: .basic)
let notesProvider = NotesProvider(presentationsData: [.displayNote: notePresentation], interactorsData: [.retrieveNotes: notesAction])
```

## State Models

Now we need a place to put the view state and the logic for handling these events. A **state model** is an object that conforms to the `StateModeling` protocol and holds a Destination's view state, business logic, lifecycle hooks, and handles Interactor requests and responses. It resides in the `DestinationInterfaceState
` object (or your own custom version), which acts as the glue between the user interface and the Destination class. The Destination itself acts as coordinator – it routes events, manages presentation lifecycle, and holds internal state, passing on requests to the state model and responding to requests from it.

Here's a sketch of NotesState. It holds the `items` and `selectedItem` properties the View observes, makes the initial Notes retrieval when the Destination first appears, and updates `items` when the Interactor returns a result. 
```swift
@Observable
final class NotesState: StateModeling {
    typealias Destination = NotesDestination
    typealias EventType = Destination.Events
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var items: [NoteModel] = []
    var selectedItem: NoteModel.ID?

    func prepareForAppearance(isVisible: Bool) {
        if isVisible {
            destination?.handleThrowable { [weak destination] in
                try destination?.performAction(for: .retrieveNotes)
            }
        }
    }

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
}
```

If you assign the `stateModel` property on your View's `DestinationStateable
` object as a protocol, you suddenly have a business logic and datasource layer that's swappable with any objects that conform to that protocol. You can for instance substitute a mock implementation in tests or switch between concrete state classes at runtime for A/B testing, without touching the Destination, the user interface, or the routing layer.

So with a relatively small amount of code we've created an interaction where the NotesView knows nothing about the Note detail screen or that it should be presented in the `NavigationStack`. And we created a second event that retrieves Notes to populate the NotesView list, where that `View` knows nothing about the datasource and never interacted with it directly. All of that presentation code, boilerplate SwiftUI navigation code, and the associated logic is handled by Destinations internally once you conform your View or UIViewController to the appropriate Destinations protocol.

Because of that pairing between event type and presentation action, we've also opened up the ability to quickly reconfigure what the Note's list item displays when tapped. Let's say the product team wants to have the button to present a detail screen with an alternate design. That's as easy as creating a new `DestinationPresentation` and assigning it to the `displayNote` type. Or if the product team wants to A/B test with these two detail views, we can create a new event type and switch the type being sent as necessary. Or perhaps we want to have an alternate test datasource that pulls from a local JSON file instead for testing. The only change required is to swap the datasource linked to the interface action. This flexibility makes it possible to quickly test new behaviors and change the routing paths in your app without editing several files. Less code, less time, less potential bugs.

If that sounds appealing, check out the **[user guide](Guides/UserGuide.md)** and the examples projects to dive deeper into Destinations!


### Requirements

* Xcode 16.0+
* iOS 17+
* Swift 6.0 or above. It has been tested against Swift 6 Strict Concurrency.

### Migration Guides

* [2.0 Migration Guide](Guides/MigrationGuide2.0.md)
* [3.0 Migration Guide](Guides/MigrationGuide3.0.md)

### Installation

You can add Destinations to an Xcode project by adding it as a Swift package dependency.
```swift
.product(name: "Destinations", package: "Destinations")
```

### License

This library is released under the MIT license. See [LICENSE](LICENSE.md) for details.

I'd love to know if you use Destinations in your projects!
