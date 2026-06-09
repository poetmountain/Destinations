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

Please be sure to check out the [Examples projects](Examples) to see some simple implementations of Destinations in UIKit and SwiftUI apps, or dive deep into the source [Documentation](https://poetmountain.github.io/Destinations/).

## Overview

Keeping application logic, tight couplings to datasources and system APIs, and knowledge of other views out of your user interfaces can be a constant battle, compounded by often tight timelines to get a feature shipped. Destinations is a library designed from the ground up to address this problem.

In Destinations, user interfaces have no knowledge of the actions they should take. They have no knowledge of datasources, business logic, or other UI screens, either. These things – View presentations, API requests, logic – are handled by state models you create which and interface with the View's Destination. Actions that can be taken in a particular Destination are represented by an enum of events you define. Thus, when a user interacts with a UI element the only thing the View sends along to the state model is the event's enum value. In this way, app functionality is no longer tightly coupled to UI and can be switched or modified easily. A button in View A can display View B, even though A has no knowledge of B, or even that it should present a View! A button could make a server request or show a modal sheet simply by switching its associated action, with no direct knowledge of either.

But more than that, abstracting navigation and View presentation actions, along with datasource request handling, enables Destinations to act as a framework for your app's feature flows. In fact Destinations handles most UIKit and SwiftUI presentation tasks for you, allowing you to focus on your app's functionality instead of writing boilerplate code.

There's a few main conceptual types in Destinations:  
**Flow:** Manages the creation, appearance, and removal of Destinations as a user navigates through the app.  
**Destination:** Represents a distinct view in the app, and coordinates routing and requests. Generally not directly used.  
**State Model:** Custom objects specific to each Destination which handle view state, business logic, and responds to events sent by the view.  
**Provider:** Builds and configures a Destination, its view, and the state model. Used by Flow object to present new views.  
**Interactor:**  Provide an interface to perform a task or data request, typically by interfacing with an backend API, interfacing with system frameworks, or some other self-contained work.  

## Presenting a Destination

A Destination's role in the ecosystem is to represent a discrete user interface screen within the framework and coordinate on behalf of that interface. Generally you will create one of the default classes, `ViewDestination` or `ControllerDestination` for SwiftUI or UIKit projects respectively, in the Provider and never deal with them again within your app.

Let's say we have a SwiftUI app which shows user Note objects in a `List` in NotesView. We want to create a detail screen that will be pushed onto the `NavigationStack` when a user taps on a Note list item. To do that we should create a `DestinationPresentation` object which represents that action. This object contains the type of Destination to present, the `presentationType` which represents *how* the Destination should be presented, and the `assistantType` which represents the kind of presentation assistant to be used (`basic` is usually fine).
```swift
let notePresentation = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .noteDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
```

In order for the NotesView to be aware of this presentation action we need to feed it into a Provider which builds the Destination, the StateModel, and the associated NotesView. The `presentationsData` dictionary in the example below associates a specific event type with a specific presentation action Destinations should take. So when NotesView sends this event to the StateModel with a `handleEvent(...)` call, this presentation should be implemented and the detail view will be shown.
```swift
let notesProvider = NotesProvider(presentationsData: [.displayNote: notePresentation])
```

In the example below, we're passing that event type from NotesView to its state model along with the Note model we should display in the detail view. (We'll cover state models in the next section, but for now just know that they hold the view's state and business logic.)
```swift
.onChange(of: stateModel.selectedItem, { [weak stateModel = stateModel] (oldValue: UUID?, newValue: UUID?) in
    if let newValue, let stateModel, let item = stateModel.items.first(where: { $0.id == newValue }) {
        stateModel.handleEvent(.displayNote, content: .note(model: item))
    }
})
```

## State Models

A **state model** is an object that conforms to the `StateModeling` protocol and holds a Destination's view state, business logic, lifecycle hooks, as well as handling Interactor requests and responses. It resides in a `DestinationStateable` object you generally create for each View, and which acts as the glue between the user interface and the Destination class.

Here's a sketch of NotesState. It holds the `items` and `selectedItem` properties the View observes, makes the initial Notes retrieval when the Destination first appears, and updates `items` when the Interactor returns a result. 
```swift
@Observable
final class NotesState: StateModeling {
    typealias Destination = NotesView.Destination
    typealias EventType = NotesView.Events
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var items: [Note] = []
    var selectedItem: Note.ID?

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
                break
        }
    }
}
```

If you instead define a custom protocol that your state model conforms to, you suddenly have a business logic and datasource layer that's swappable with any objects that conform to that protocol. You can for instance substitute a mock implementation in tests or switch between concrete state classes at runtime for A/B testing, without touching the Destination, the user interface, or the routing layer.

Here's an example of a protocol layer for our Notes state model:
```swift
@MainActor protocol NotesStateModeling: StateModeling, AnyObject, Identifiable where Destination == NotesView.Destination {
    typealias EventType = NotesView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var id: UUID { get }
    var items: [Note] { get set }
    var selectedItem: Note.ID? { get set }
}
```

## Making a Datasource Request

Continuing our Notes example, let's hook up an **Interactor** so that we can provide Note models to the list `View`. Interactors house any kind of logic that we want to keep isolated from the UI, such as datasource retrievals, API requests, etc.

So let's start by creating a sketch of a datasource Interactor for our Notes. The `perform(request:) async -> Result<NotesRequest.ResultData, Error>` method here is part of the `AsyncInteractable` protocol and will be called when NotesState makes a request to the Destination with `performAction(...)`. The NotesRequest `action` types we switch on in the example below represent the possible actions that the Interactor supports. Once the method retrieves the relevant Note models, it should package them up in a Result and return them.
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

Now that we have a datasource and a way to make requests of it, we need to enable the state model to call it. We can do this with `InteractorConfiguration` models. These objects specify the type of Interactor being called, the type of action the Interactor should take, and the type of Interactor assistant that should be used. (Interactor assistants handle communication between the Destination and the Interactor) 

All interactor actions should go into the `interactorsData` dictionary parameter of the Provider which creates the Destination that should call it. Here we've assigned the Notes retrieval action to a new event type `retrieveNotes`.
```swift
let notesAction = InteractorConfiguration<NotesDestination.InteractorType, NotesDatasource>(interactorType: .notes, actionType: .retrieve, assistantType: .basic)
let notesProvider = NotesProvider(presentationsData: [.displayNote: notePresentation], interactorsData: [.retrieveNotes: notesAction])
```

So with a relatively small amount of code we've created an interaction where NotesView knows nothing about the Note detail screen or that it should be presented in the `NavigationStack`. And we created a second event that retrieves Notes to populate the NotesView list, where that `View` knows nothing about the datasource and never interacted with it directly. All of that presentation code, boilerplate SwiftUI navigation code, and the associated logic is handled by Destinations internally once you conform your View or UIViewController to the appropriate Destinations protocol.

Because of that pairing between event type and presentation action, we've also opened up the ability to quickly reconfigure what the NoteView's list items display when tapped. Let's say the product team wants to have the tap action present a detail screen with an alternate design. That's as easy as creating a new `DestinationPresentation` and assigning it to the `displayNote` type. Or if the product team wants to A/B test with different business logic on the view, we can simply create a new state model using a shared protocol and assign them to the View as needed. Or perhaps we want to have an alternate test datasource that pulls from a local JSON file instead for testing. The only change required is to swap the datasource linked to the interface action. This flexibility makes it possible to quickly test new behaviors and change the routing paths in your app without editing several files. And because everything is tied to enum states, we reduce ambiguity about the result of actions taken. Less code, less time, less potential bugs.

If that sounds appealing, check out the **[user guide](Guides/UserGuide.md)** and the examples projects to dive deeper into Destinations!


### Requirements

* Xcode 16.0+
* iOS 17+
* Swift 6.0 or above.

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
