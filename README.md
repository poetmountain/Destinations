# Destinations
![Static Badge](https://img.shields.io/badge/Swift-6.0-005AA5.svg) ![Static Badge](https://img.shields.io/badge/Platforms-iOS-005AA5.svg) ![License](https://img.shields.io/badge/License-MIT-005AA5.svg "License")

Destinations is a Swift library for UIKit and SwiftUI that is designed to remove application and business logic from your interfaces, manage navigation flow, and abstract datasource interactions so that your user interfaces can focus again on the user. It is based on a philosophy that emphasizes clear separation of concerns, that each significant `View` or `UIViewController` in an app should not know about each other, and that UI and functionality should be able to be easily substituted as your needs change.

* Enables clean separation of concerns between your interfaces, datasources, and other application logic
* Allows you to easily replace UI and datasources for A/B testing or providing testing mocks
* Reduces development time – provides built-in implementations for many navigation and presentation types, reduces code churn as feature flows change
* Provides easy deep linking capability
* Provides the ability to display and test sections of your apps in isolation
* A flexible and extensible, protocol-based system to fit your project's needs, including custom UI
* A similar API for both UIKit and SwiftUI, and generic enough to allow further platform support. Supports pure UIKit and SwiftUI apps, but also supports hybrid apps with SwiftUI content hosted within UIKit controllers.
* Full [documentation](https://poetmountain.github.io/Destinations/)

## Getting Started

#### Get started with the **[user guide](Guides/UserGuide.md)** for detailed explanations and examples.

If you're upgrading from a previous version of Destinations, check out the [2.0 Migration Guide](Guides/MigrationGuide2.0.md) for breaking changes.

Also check out the [Examples projects](Examples) to see Destinations in action in UIKit and SwiftUI, or dive deep into the source [Documentation](https://poetmountain.github.io/Destinations/).

## Overview

Keeping application logic, tight couplings to datasources and system APIs, and knowledge of other views out of your views and view controllers can be a constant battle, compounded by often tight timelines to get a feature shipped. Destinations is a library designed from the ground up to address this problem.

Destinations is designed to represent each significant interface element – typically one that would be presented as the active view on the screen and can be routed to – as an abstract object that conforms to the `Destinationable` protocol. For shorthand I'll refer to these objects as a **Destination**. A Destination's role in the ecosystem is to represent a discrete user interface screen and to manage user interaction events and Interactor requests on behalf of that interface. And what is an Interactor? Think of it as a black box you can attach to a Destination which handles logic, system APIs, or datasource requests. It could be as simple as a counter or as complex as a cloud syncing service. A Destination doesn't handle any UI directly though; that remains the responsibility of the interface. A Destination allows its interface to focus on that task. And then above the Destination is the Flow object, which as you might expect manages the flow from Destination to Destination as a user navigates through the app, presenting each Destination that is built using a Provider and using configuration models you have defined.

## Presenting a Destination

Let's say we have a SwiftUI app which shows user Notes in a `List` in a NotesView `View`, backed by a NotesDestination. We want to create a detail screen that will be pushed onto the `NavigationStack` when a user taps on a Note list item. To do that we should create a `DestinationPresentation` object which represents that action. This object contains the type of Destination to present, the `presentationType` which represents *how* the Destination should be presented, and the `assistantType` which represents the kind of presentation assistant to be used (we'll talk more about those in a bit). Often you can just use the `basic` assistant if you don't need to pass along any state.
```swift
let notePresentation = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .noteDetail, presentationType: .navigationStack(type: .present), assistantType: .custom(SelectNoteAssistant())
```

In order for the NotesView containing the list of Notes to be aware of this user action, we need to feed the action into a Provider object which builds the NotesDestination and the associated NotesView. The `presentationsData` dictionary in the example below pairs user interaction types for that Destination with a presentation configuration model. Effectively, we're associating a particular type of user interaction with a specific action which Destinations should take. So in this example, we're supplying a configuration to the NotesDestination that when a user taps a Note list item and causes the `displayNote` interaction type to be sent, the presentation action should be run, which will create the Note detail Destination and present its associated `View` on-screen by pushing it onto the `NavigationStack`.
```swift
let notesProvider = NotesProvider(presentationsData: [.displayNote: notePresentation])
```

Now that we have a defined interface action for presenting the detail `View` and linked it to the `displayNote` user interaction type, we need to connect it to our interface. Assuming we have an `onChange` modifier in the NotesView watching a `selectedItem` property, we can pass that user interaction type to its Destination, along with a `content` parameter providing the selected Note model we should display in the new detail `View`. (The `handleThrowable()` method here automatically handles any throws that occur from calling the `performInteraceAction()` method)
```swift
.onChange(of: selectedItem, { [weak destinationState] oldValue, newValue in
	if let newValue, let item = destinationState?.destination.items.first(where: { $0.id == newValue }) {
        destination().handleThrowable {
            try self.destination().performInterfaceAction(interactionType: .displayNote, content: .note(model: item))
        }
	}
})
```

There's one more step. We need a presentation assistant. We saw those before when creating the `DestinationPresentation` object. These assistants handle the user interaction, configuring an `InterfaceAction` which will drive the presentation of the new Destination. Usually, creating a custom assistant like this isn't necessary, but in this case we're passing along a Note model to the detail `View` so we need an assistant that can handle that.
```swift
struct SelectNoteAssistant: InterfaceActionConfiguring {
    typealias UserInteractionType = NotesDestination.UserInteractions
    typealias DestinationType = AppDestinationType
    typealias ContentType = AppContentType
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType? = nil) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var action = interfaceAction
        
        var contentType: ContentType?
                
        if case .note(model: let model) = interactionType {
            if let model {
                contentType = .note(model: model)
            }
            
            action.data.contentType = contentType
            action.data.parentID = destination.id
        }

        return action
    }
}
```

## Making a Datasource Request

Continuing our Notes example, let's hook up a datasource **Interactor** so that we can provide Note models to the list `View`. Interactors house any kind of logic that we want to keep isolated from the UI -- datasource retrievals, system API requests, etc.

So let's start by creating a sketch of a datasource Interactor for our Notes. The `perform(request:) async -> Result<NotesRequest.ResultData, Error>` method here is part of the `AsyncDatasourceable` protocol and will be called when our Notes Destination makes a request by passing in a NotesRequest. The `action` types we switch on represent the possible actions that the Interactor supports. Once the method retrieves the relevant Note models, it should package them up in a Result and return them.
```swift
actor NotesDatasource: AsyncDatasourceable {
    typealias Request = NotesRequest
    typealias Item = Request.Item
                
    var items: [Item] = []
    
    func perform(request: Request) async -> Result<NotesRequest.ResultData, Error> {
    
        switch request.action {
            case .retrieve:
                return await self.retrieveNotes(request: request)
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

Now that we have a datasource and a way to make requests of it, we need to make an interface action which will represent a specific request. For Interactor interface actions we should use`InteractorConfiguration` to represent them. It specifies the type of Interactor being called (this enum type should be assigned to one using a Destination's `assignInteractor` method), the type of action the Interactor should take, and the type of Interactor assistant that should be used. (Interactor assistants create the actual Request and handle communication between the Destination and the Interactor) 

As with our `View` presentation, we can pass this action, paired with a user interaction type which should call it, in to the Provider which creates the Notes list `View`. All interactor actions should go into the `interactorsData` dictionary parameter. Here we've assigned the Notes retrieval action to a new user interaction type `retrieveNotes`.
```swift
let notesAction = InteractorConfiguration<NotesDestination.InteractorType, NotesDatasource>(interactorType: .notes, actionType: .retrieve, assistantType: .basic)
let notesProvider = NotesProvider(presentationsData: [.displayNote: notePresentation], interactorsData: [.retrieveNotes: notesAction])
```

Connecting this interface action to the UI works just the same as with Destination presentations. In our case we want to make an initial retrieval from NotesDatasource when the NotesDestination is first presented so that the Notes list is populated with data. Fortunately there's a `prepareForPresentation()` method we can implement on NotesDestination and make this interface action request there. That method is a good place to put any kind of configuration or Interactor operations as its UI is being presented.
```swift
destination().handleThrowable {
    try self.destination().performInterfaceAction(interactionType: .retrieveNotes)
}
```

We've connected one side of the Interactor request flow for our Notes retrieval operation, but we still need to handle the result of the request. For an Interactor that conforms to `AsyncInteractable` or `AsyncDatasourceable` as the NotesDatasource does, the result is presented to the calling Destination's `handleInteractorResult()` method. So assuming we have an `items` array on NotesDestination which our NotesView list observes, we can write something like this:
```swift
func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async {
    
    switch result {
        case .success(let content):
            switch content as? NotesRequest.ResultData {
                case .notes(models: let items):
                    self.items = items
                default: break
            }
            
        case .failure(let error):
            logError(error: error)
    }
}
```

So with a relatively small amount of code we've created an interaction where the Notes list `View` knows nothing about the Note detail screen or that it should be presented in the `NavigationStack`. And we created a second interaction that retrieves Notes to populate the NotesView list, where that `View` knows nothing about the datasource and never interacted with it directly. All of that presentation code, boilerplate SwiftUI navigation code, and the associated logic is handled by Destinations internally.

Because of that pairing between user interaction type and presentation action, we've also opened up the ability to quickly reconfigure what the Note's list item displays when tapped. Let's say the product team wants to have the button to present a detail `View` with an alternate design. That's as easy as creating a new `DestinationPresentation` and assigning it to the `displayNote` type. Or if the product team wants to A/B test with these two detail views, then additionally create a new user interaction type and switch the type being called as necessary. Or perhaps we want to change the Notes datasource to pull from a local cache instead. The only change required is to swap the datasource linked to the interface action. This flexibility makes it possible to quickly test new behaviors and change the routing paths in your app without editing several files. Less code, less time, less potential bugs.

If that sounds appealing, check out the **[user guide](Guides/UserGuide.md)** and the examples projects to dive deeper into Destinations!


### Requirements

* Xcode 16.0+
* iOS 17+
* Swift 6.0 or above. It has been tested against Swift 6 Strict Concurrency.

### Installation

You can add Destinations to an Xcode project by adding it as a Swift package dependency.
```swift
.product(name: "Destinations", package: "Destinations")
```

### License

This library is released under the MIT license. See [LICENSE](LICENSE.md) for details.

I'd love to know if you use Destinations in your projects!
