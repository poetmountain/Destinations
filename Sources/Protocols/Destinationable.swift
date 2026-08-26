//
//  Destinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

@MainActor
public protocol InteractorResultHandling<InteractorType, ContentType>: Sendable, AnyObject {
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    associatedtype ContentType: ContentTypeable
    
    
    /// Handles the result of an Interactor request in a synchronous context.
    /// - Parameters:
    ///    - result: The Result object containing data returned from the request.
    ///    - request: The original request used in this Interactor operation.
    func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request)
    
    /// Handles the result of an async Interactor request.
    /// - Parameters:
    ///    - result: The Result object containing data returned from the request.
    ///    - request: The original request used in this Interactor operation.
    func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async
    
    /// Performs a request with the specified Interactor.
    /// - Parameters:
    ///   - interactor: The type of Interactor that should receive the request.
    ///   - request: A model that defines the request.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request)
    
    /// Performs a request with the specified Interactor asynchronously.
    /// - Parameters:
    ///   - interactor: The type of Interactor that should receive the request.
    ///   - request: A model that defines the request.
    /// - Returns: A `Result` containing an array of items.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<Request.ResultData, Error>
    
    /// Returns an Interactor for the specified type.
    /// - Parameter type: The enum type of an Interactor.
    /// - Returns: An Interactor, if one was found.
    func interactor(for type: InteractorType) -> (any AbstractInteractable)?
}

/// This protocol represents a Destination in the Destinations ecosystem.
///
/// A Destination represents a unique area in an app which can be navigated to by the user. In SwiftUI this is typically a fullscreen `View` object, and in UIKit it's a `UIViewController` class or subclass, but it can also be a group of Destinations like a `TabBar` or a carousel. Destinations hold references to the UI element they're associated with, but they don't handle the particulars of laying out elements on the screen. Instead, the role of Destination objects in the ecosystem is to send and receive messages and datasource requests on behalf of their UI, such as passing on a message to trigger an action when a user taps a button.
///
/// In most cases you should be able to use the provided `ViewDestination` or `ControllerDestination` classes for SwiftUI or UIKit apps respectively. They are customized to a particular Destination through generic arguments.  To handle presentation requests that require specialized configuration or need to handle content models, you can create custom assistants which conform to the `InterfaceActionConfiguring` protocol. To handle requests to an interactor, you can create assistants which conform to the `InteractorAssisting` protocol. There are more specific classes to support interfaces like TabBars, but you can also use your own Destination classes by conforming to `ViewDestinationable` or `ControllerDestinationable` if you should need custom functionality or just want to avoid using generics.
///
/// There is a two-way connection between a Destination and its interface which is handled by a `DestinationStateable`-conforming object. Destinations comes with a `DestinationInterfaceState` object which can be used for this purpose, though you can create your own class if you'd like to store other state in it. When a Destination is removed from the ecosystem, cleanup is done internally to ensure no retain cycles occur.
@MainActor public protocol Destinationable<DestinationType, ContentType, TabType>: AnyObject, Identifiable, InteractorResultHandling, AssistantAssigning where InteractorType: InteractorTypeable, ContentType: ContentTypeable  {
    
    /// An enum which defines event types for this Destination's interface.
    associatedtype EventType: EventTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
           
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines available Destination presentation types.
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    typealias DestinationConfigurations = AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>
    
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>
    

    /// The unique identifier for this Destination.
    var id: UUID { get }

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    var type: DestinationType { get }
    
    /// State object for handling functionality for the Destinations ecosystem.
    var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> { get set }

    /// A state model that handles business logic and view state for this Destination.
    var stateModel: (any StateModeling<Self>)? { get set }

    /// Performs the action associated with the specified event type. This action could be a Destination presentation or a request to an Interactor.
    /// - Parameter eventType: The event type whose action should be run.
    /// - Parameter content: Optional content to use with the action.
    func performAction(for eventType: EventType, content: ContentType?) throws
    
    /// Asynchronously performs the action associated with the specified event type and returns a Result. Generally this would be used to perform an Interactor action instead of a Destination presentation.
    /// - Parameter eventType: The event type whose action should be run.
    /// - Parameter content: Optional content to use with the action.
    func performAction(for eventType: EventType, content: ContentType?) async -> Result<ContentType, Error>
    
    /// Performs the action sequence associated with the specified event type, running each of its Interactor actions in order and passing the result of each action to the next one through its output conduit. The sequence will run until either all actions have completed, an action returns an error, or the sequence is cancelled.
    /// - Parameter eventType: The event type corresponding to the action sequence to be run.
    /// - Parameter content: Optional content to pass to the sequence. Each step in the sequence determines how this content should be used, but generally it should be passed in with the first action's Interactor request.
    /// - Returns: A `Result` containing an ``ActionSequenceResults`` object which holds the results of each completed action, or an `Error` if the sequence could not be built or one of its actions failed. If the sequence was cancelled, the failure contains an ``ActionError/cancelled(partialResults:)`` error holding the results of any actions which completed before cancellation occurred.
    func performActions(for eventType: EventType, content: ContentType?) async -> Result<ActionCollectionResults<ContentType>, any Error>
    
    /// Performs a custom action sequence using the provided configuration, running each of its Interactor actions in order and passing the result of each action to the next one through its output conduit. The sequence will run until either all actions have completed, an action returns an error, or the sequence is cancelled.
    ///
    /// Use this overload when you want to supply a sequence configuration directly rather than relying on one pre-registered with the event type.
    /// > Important: Use of this method (and the lack of eventType to reference in ``cancelActionSequence(for:)-1z0z5`` means that the caller responsible for task cancellation by saving the Task wrapping this method to a property and calling `Task.cancel()` on it.
    /// - Parameter configuration: An object conforming to ``ActionCollectionConfiguring`` which defines the sequence of Interactor actions to run.
    /// - Parameter content: Optional content to pass to the sequence. Each step in the sequence determines how this content should be used, but generally it should be passed in with the first action's Interactor request.
    /// - Returns: A `Result` containing an ``ActionSequenceResults`` object which holds the results of each completed action, or an `Error` if the sequence could not be built or one of its actions failed. If the sequence was cancelled, the failure contains an ``ActionError/cancelled(partialResults:)`` error holding the results of any actions which completed before cancellation occurred.
    func performActions(configuration: any ActionCollectionConfiguring<InteractorType, ContentType>, content: ContentType?) async -> Result<ActionCollectionResults<ContentType>, any Error>

    /// Cancels all in-progress action sequences on this Destination. This is called automatically by a Flow when this Destination is removed from it.
    func cancelAllActionSequences()
    
    /// Performs the action associated with the specified event type.
    /// - Parameter eventType: The event type whose action should be run.
    /// - Parameter content: Optional content to use with the action.
    @available(*, deprecated, renamed: "performAction(for:content:)", message: "This method is deprecated and will be removed in a future version. Please migrate your code to use the `performAction(for:content:)` method instead.")
    func performInterfaceAction(eventType: EventType, content: ContentType?) throws
    
    /// Builds the ``InterfaceAction`` objects to handle Destination presentations generated by this Destination. This should be called when configuring a Destination for presentation, typically from a ``Flowable`` object.
    /// - Parameter presentationClosure: The presentation closure to be used in building the ``InterfaceAction`` objects.
    func buildInterfaceActions(presentationClosure: @escaping (_ configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> Void)
    
    /// Builds an ``InterfaceAction`` object to handle the specified Destination presentation.
    /// - Parameters:
    ///   - presentationClosure: A presentation closure to be used in building the ``InterfaceAction`` object.
    ///   - configuration: A model object used to configure the presentation.
    ///   - eventType: The event type associated with this presentation.
    /// - Returns: An ``InterfaceAction`` object for this presentation.
    func buildInterfaceAction(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, eventType: EventType) -> InterfaceAction<EventType, DestinationType, ContentType>
    
    /// Builds the ``InterfaceAction`` objects to handle requests for this Destination's interactors.
    /// - Parameter presentationClosure: The presentation configuration object closure. Currently this is unused.
    func buildInteractorActions(presentationClosure: @escaping (_ configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> Void)

    /// Updates the interface actions associated with this Destination.
    /// - Parameter closures: An array of ``InterfaceAction`` objects containing user interaction closures to be run.
    func updateInterfaceActions(actions: [InterfaceAction<EventType, DestinationType, ContentType>])
    
    /// Builds the system navigation actions. This should be called when configuring a Destination for presentation, typically from a ``Flowable`` object.
    /// - Parameter presentationClosure: A closure passing in a presentation configuration object to be used in building the system navigation closures.
    func buildSystemNavigationActions(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void)
    
    /// Builds a system navigation action.
    /// - Parameters:
    ///   - presentationClosure: A closure which helps build the associated ``InterfaceAction``.
    ///   - configuration: A model object which helps configure the system navigation action.
    ///   - navigationType: The type of system navigation event associated with this action.
    /// - Returns: An ``InterfaceAction`` object for this system event.
    func buildSystemNavigationAction(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, navigationType: SystemNavigationType) -> InterfaceAction<SystemNavigationType, DestinationType, ContentType>
    
    /// Updates the system navigation closures associated with this Destination.
    /// - Parameter closures: An array of ``InterfaceAction`` objects containing system navigation closures to be run.
    func updateSystemNavigationActions(actions: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>])

    /// Returns a presentation configuration object based on its identifier.
    /// - Parameter presentationID: The identifier of a presentation configuration object.
    /// - Returns: The configuration object, or `nil` if the specified object was not found.
    func presentation(presentationID: UUID) -> (DestinationPresentation<DestinationType, ContentType, TabType>)?
    
    /// Returns a system navigation configuration object based on its identifier.
    /// - Parameter presentationID: The identifier of a presentation configuration object.
    /// - Returns: The system navigation configuration object, if one was found.
    func systemNavigationPresentation(presentationID: UUID) -> (DestinationPresentation<DestinationType, ContentType, TabType>)?
    
    /// Returns a presentation configuration object based on its associated user interaction event type.
    /// - Parameter eventType: The user interaction event type.
    /// - Returns: The configuration object, or `nil` if the specified object was not found.
    func presentation(for eventType: EventType) -> (DestinationPresentation<DestinationType, ContentType, TabType>)?
    
    /// Returns a system navigation configuration object based on its associated type.
    /// - Parameter navigationType: The system navigation type.
    /// - Returns: The configuration object, or `nil` if the specified object was not found.
    func systemNavigationPresentation(for navigationType: SystemNavigationType) -> (DestinationPresentation<DestinationType, ContentType, TabType>)?
    
    /// Updates an existing presentation with a new configuration object. If no presentation is found which matches this object's identifier, nothing is updated.
    /// - Parameter presentation: The presentation configuration object to replace an existing one.
    func updatePresentation(presentation: DestinationPresentation<DestinationType, ContentType, TabType>)
    
    /// Updates an existing system navigation presentation with a new configuration object. If no system navigation object is found which matches this object's identifier, nothing is updated.
    /// - Parameter presentation: The presentation configuration object to replace an existing one.
    func updateSystemNavigationPresentation(presentation: DestinationPresentation<DestinationType, ContentType, TabType>)
    
    /// Assigns an Interactor to this Destination. An Interactor handles specialized tasks and interactions with other APIs for the Destination.
    /// - Parameters:
    ///   - interactor: The Interactor to add.
    ///   - type: Specifies the enum type of this Interactor. This type can be used to look up the Interactor.
    @available(*, deprecated, renamed: "assignInteractor(_:to:)", message: "This method is deprecated and will be removed in a future version. Please migrate your code to use the `assignInteractor(_:to:)` method instead.")
    func assignInteractor<Request: InteractorRequestConfiguring>(interactor: any AbstractInteractable<Request>, for type: InteractorType)
    
    /// Assigns an Interactor to this Destination. An Interactor handles specialized tasks and interactions with other APIs for the Destination.
    /// - Parameters:
    ///   - interactor: The Interactor to add.
    ///   - type: Specifies the enum type of this Interactor. This type can be used to look up the Interactor.
    func assignInteractor<Request: InteractorRequestConfiguring>(_ interactor: any AbstractInteractable<Request>, to type: InteractorType)
    
    /// Returns an Interactor for the specified type.
    /// - Parameter type: The enum type of an Interactor.
    /// - Returns: An Interactor, if one was found.
    func interactor(for type: InteractorType) -> (any AbstractInteractable)?
    
    /// Configures the Interactor that is assigned to this Destination. You may use this method to make any initial requests to the Interactor to set up the interface's initial state. This method is called automatically when an Interactor is assigned to it.
    /// - Parameters:
    ///   - interactor: The Interactor to configure requests for.
    ///   - type: The type of interactor.
    func configureInteractor(_ interactor: any AbstractInteractable, type: InteractorType)
    
    /// Configures all Interactors that are assigned to this Destination. This method is called internally by this Destination's Provider.
    func configureInteractors()
    
    /// Adds an interface action.
    /// - Parameters:
    ///   - closure: The closure to add.
    func addInterfaceAction(action: InterfaceAction<EventType, DestinationType, ContentType>) throws
    
    /// Adds a system navigation closure.
    /// - Parameters:
    ///   - closure: The closure to add.
    func addSystemNavigationAction(action: InterfaceAction<SystemNavigationType, DestinationType, ContentType>)
    
    /// Assigns an Interactor assistant to a specific event type.
    /// - Parameters:
    ///   - assistant: The Interactor assistant to add.
    ///   - eventType: The type of event which this assistant should handle requests for.
    func assignInteractorAssistant(assistant: any InteractorAssisting<InteractorType, ContentType>, for eventType: EventType)

    /// This method is called automatically when a Destination is presented by a Flow for the first time, but before its associated UI is built. Implement this method in your Destination classes to put any initial state setup actions or datasource retrieval calls here that should only be run when a Destination is first created.
    ///
    /// > Unlike ``prepareForAppearance(isVisible:)``, this method is only called once on a Destination.
    func prepareForPresentation()
    
    /// This method is called automatically when a Destination is about to be presented by a Flow, prior to the associated UI element appearing on-screen. Implement this method in your Destination classes to place any setup tasks that need to be run each time the Destination's UI element becomes active.
    ///
    /// > This method is preferred and is often more reliable than using native UI hooks like `View`'s `onAppear` modifier in SwiftUI projects.
    /// - Parameters:
    ///   - isVisible: Represents whether this Destination will actually be visible on-screen when it is presented. If this Destination was presented within the middle of a Destination path presentation, it would be `false`. This is useful for instance if you wish to avoid calling setup tasks unless it is the final Destination in a path presentation.
    func prepareForAppearance(isVisible: Bool)
    
    /// This method is called automatically when a Destination is about to become inactive. Implement this method in your Destination classes to place any teardown tasks that need to be run each time the Destination's UI element is no longer visible or the active element.
    ///
    /// > This method is preferred and is often more reliable than using native UI hooks like `View`'s `onDisappear` modifier in SwiftUI projects, and especially in cases where several UI elements may be added in quick succession in a `NavigationStack`.
    /// - Parameters:
    ///   - wasVisible: Represents whether this Destination which is disappearing was actually visible on-screen. If this Destination was presented within the middle of a Destination path presentation, it would be `false`.
    func prepareForDisappearance(wasVisible: Bool)
    
    /// Performs a request with the specified Interactor.
    /// - Parameters:
    ///   - interactor: The type of Interactor that should receive the request.
    ///   - request: A model that defines the request.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request)
    
    /// Performs a request with the specified Interactor asynchronously.
    /// - Parameters:
    ///   - interactor: The type of Interactor that should receive the request.
    ///   - request: A model that defines the request.
    /// - Returns: A `Result` containing an array of items.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<Request.ResultData, Error>
    
    /// Performs a system navigation action, executing the closure associated with the provided system navigation type.
    /// - Parameters:
    ///   - navigationType: The type of system navigation event to perform.
    ///   - options: An optional options object for use with the closure.
    func performSystemNavigationAction<T>(navigationType: SystemNavigationType, options: T?)
    
    /// Sets the parent Destination identifier of this child.
    /// - Parameter id: The identifier of the parent Destination.
    func setParentID(id: UUID)
    
    /// Updates the `isSystemNavigating` property of the internal state.
    /// - Parameter isNavigating: The new value.
    func updateIsSystemNavigating(isNavigating: Bool)
    
    /// Returns the current value of the `isSystemNavigating` property of the internal state.
    /// - Returns: The current value.
    func isSystemNavigating() -> Bool
    
    /// When this method is called, the Destination is about to be removed from the Flow. Any resource references should be removed and in-progress interactor tasks should be stopped.
    /// > Note: In-progress action sequences do not need to be handled here; the Flow cancels them automatically when removing the Destination.
    func cleanupResources()
    
    /// Removes the associated interface from this Destination. This method is called automatically when a Destination is removed in order to avoid a retain cycle.
    func removeAssociatedInterface()
    
    /// Returns the identifier of this Destination's parent, if one exists.
    /// - Returns: The parent identifier.
    func parentDestinationID() -> UUID?
    
    /// Provides a way to catch and log Destinations errors from throwable code.
    /// - Parameters:
    ///   - closure: The throwable code to run.
    ///   - catchClosure: An optional closure to run if the try is caught.
    func handleThrowable(closure: @escaping () throws -> Void, catchClosure: (() -> Void)?)
    
    /// Logs an error to the Destinations logger. It handles DestinationError messages appropriately.
    /// - Parameter error: The Error to log.
    func logError(error: Error)
}

// default function implementations
public extension Destinationable {

    var stateModel: (any StateModeling<Self>)? {
        get { nil }
        set { }
    }

    func prepareForPresentation() {
        stateModel?.prepareForPresentation()
    }
    
    func prepareForAppearance(isVisible: Bool) {
        stateModel?.prepareForAppearance(isVisible: isVisible)
    }

    func prepareForDisappearance(wasVisible: Bool) {
        stateModel?.prepareForDisappearance(wasVisible: wasVisible)
    }
    
    func cleanupResources() {
        stateModel?.cleanupResources()
    }
    
    internal func setupInternalState() {
        internalState = DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType>()
    }
    
    func setParentID(id: UUID) {
        internalState.parentDestinationID = id
    }
    
    func presentation(presentationID: UUID) -> (DestinationPresentation<DestinationType, ContentType, TabType>)? {
        return internalState.destinationConfigurations?.configurations.values.first { $0.id == presentationID }
    }
    
    func systemNavigationPresentation(presentationID: UUID) -> (DestinationPresentation<DestinationType, ContentType, TabType>)? {
        return internalState.systemNavigationConfigurations?.configurations.values.first { $0.id == presentationID }
    }
    
    func systemNavigationPresentation(for navigationType: SystemNavigationType) -> (DestinationPresentation<DestinationType, ContentType, TabType>)? {
        return internalState.systemNavigationConfigurations?.configurations[navigationType]
    }
    
    func presentation(for eventType: EventType) -> (DestinationPresentation<DestinationType, ContentType, TabType>)? {
        return internalState.destinationConfigurations?.configuration(for: eventType)
    }
    
    func configureInteractor(_ interactor: any AbstractInteractable, type: InteractorType) {
#if swift(>=6.1)
        stateModel?.configureInteractor(interactor, type: type)
#else
        if let stateModel {
            _forwardConfigureInteractor(stateModel, interactor: interactor, type: type)
        }
#endif
    }
    
    func configureInteractors() {
        // now that we have a state model we can call configureInteractor, which will by default forward the call to the state model
        for (type, interactor) in internalState.interactors {
            configureInteractor(interactor, type: type)
        }
    }

    /// Fix for Swift 6.0 build failure. This internal forwarding method explicitly opens the existential via SE-0352 so the constraint chain resolves at the generic call site instead of on the existential.
    ///
    /// Swift 6.1 and above has existential-opening / associated-type resolution can follow that chain transitively through the same-type where clauses on a primary-associated-type existential, so this is only needed to support building on Swift 6.0.
    internal func _forwardConfigureInteractor<SM: StateModeling>(_ sm: SM, interactor: any AbstractInteractable, type: InteractorType) where SM.Destination == Self {
        sm.configureInteractor(interactor, type: type)
    }
    
    func updatePresentation(presentation: DestinationPresentation<DestinationType, ContentType, TabType>) {
        guard let destinationConfigurations = internalState.destinationConfigurations else { return }

        for (type, configuration) in destinationConfigurations.configurations {
            
            if configuration.id == presentation.id {
                internalState.destinationConfigurations?.configurations[type] = presentation
                break
            }
        }
    }
    
    func updateSystemNavigationPresentation(presentation: DestinationPresentation<DestinationType, ContentType, TabType>) {
        guard let systemNavigationConfigurations = internalState.systemNavigationConfigurations else { return }

        for (type, configuration) in systemNavigationConfigurations.configurations {
            
            if configuration.id == presentation.id {
                internalState.systemNavigationConfigurations?.configurations[type] = presentation
                break
            }
        }
    }

    
    func buildInterfaceActions(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void) {

        guard let destinationConfigurations = internalState.destinationConfigurations else { return }

        var containers: [InterfaceAction<EventType, DestinationType, ContentType>] = []
        for (type, configuration) in destinationConfigurations.configurations {
            let container = buildInterfaceAction(presentationClosure: presentationClosure, configuration: configuration, eventType: type)
            containers.append(container)
        }
        
        updateInterfaceActions(actions: containers)
        
    }
    
    func buildInterfaceAction(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, eventType: EventType) -> InterfaceAction<EventType, DestinationType, ContentType> {

        var container = InterfaceAction<EventType, DestinationType, ContentType>(function: { [weak self] (type: EventType, data: InterfaceActionData<DestinationType, ContentType>) in
            guard let strongSelf = self else { return }
            
            if let configuration = strongSelf.internalState.destinationConfigurations?.configuration(for: type) {
                if let parentID = data.parentID ?? strongSelf.internalState.parentDestinationID {
                    configuration.parentDestinationID = parentID
                }
                if let actionTargetID = data.actionTargetID {
                    configuration.actionTargetID = actionTargetID
                }
                if let currentDestinationID = data.currentDestinationID {
                    configuration.currentDestinationID = currentDestinationID
                }
                
                if let model = data.contentType {
                    configuration.contentType = model
                }
                
                if let destinationType = data.destinationType {
                    configuration.destinationType = destinationType
                }
                
                if let presentationType = data.presentationType as? DestinationPresentationType<DestinationType, ContentType, TabType> {
                    configuration.presentationType = presentationType
                }
                
                strongSelf.internalState.destinationConfigurations?.configurations[type] = configuration
                
                presentationClosure(configuration)
            } else {
                DestinationsSupport.logger.log("Interface action closure could not be built for type \(type)", category: .error)
            }

        })
        
        container.eventType = eventType
        container.data.presentationID = configuration.id
        container.data.destinationType = configuration.destinationType
        container.data.presentationType = configuration.presentationType
        container.data.contentType = configuration.contentType
        container.data.actionType = configuration.actionType
        
        return container
    }
    
    func buildInteractorActions(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void) {

        var containers: [InterfaceAction<EventType, DestinationType, ContentType>] = []
        for (type, _) in internalState.interactorAssistants {
            let container = buildInteractorAction(presentationClosure: presentationClosure, eventType: type)
            containers.append(container)
        }
        
        updateInterfaceActions(actions: containers)
        
    }
        
    internal func buildInteractorAction(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void, eventType: EventType) -> InterfaceAction<EventType, DestinationType, ContentType> {

        var container = InterfaceAction<EventType, DestinationType, ContentType>(function: { [weak self] (type: EventType, data: InterfaceActionData<DestinationType, ContentType>) in
            guard let strongSelf = self else { return }
            
            if let assistant = strongSelf.internalState.interactorAssistants[eventType], let configuration = strongSelf.internalState.destinationConfigurations?.interactorConfiguration(for: eventType) as? any InteractorConfiguring<InteractorType>, let actionType = configuration.actionType {
                switch assistant.requestMethod {
                    case .async:
                        Task {
                            if let asyncAssistant = assistant as? any AsyncInteractorAssisting<InteractorType, ContentType> {
                                await asyncAssistant.handleAsyncRequest(destination: strongSelf, actionType: actionType, content: data.contentType)
                                
                            } else {
                                let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                                let message = String(format: template, type.rawValue)
                                strongSelf.logError(error: DestinationsError.missingInterfaceActionAssistant(message: message))
                            }
                        }
                    case .sync:
                        assistant.handleRequest(destination: strongSelf, actionType: actionType, content: data.contentType)
                }
                
                
            } else {
                let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                let message = String(format: template, type.rawValue)
                strongSelf.logError(error: DestinationsError.missingInterfaceActionAssistant(message: message))
            }

        })
        
        container.eventType = eventType

        return container
    }
    

    func buildSystemNavigationActions(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void) {

        guard let systemNavigationConfigurations = internalState.systemNavigationConfigurations else { return }

        var containers: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = []
        for (type, configuration) in systemNavigationConfigurations.configurations {
            let container = buildSystemNavigationAction(presentationClosure: presentationClosure, configuration: configuration, navigationType: type)
            containers.append(container)
        }
        
        updateSystemNavigationActions(actions: containers)
        
    }
    
    func buildSystemNavigationAction(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, navigationType: SystemNavigationType) -> InterfaceAction<SystemNavigationType, DestinationType, ContentType> {

        var container = InterfaceAction<SystemNavigationType, DestinationType, ContentType>(function: { [weak self] (type: SystemNavigationType, data: InterfaceActionData<DestinationType, ContentType>) in
            guard let strongSelf = self else { return }
            

            if let configuration = strongSelf.internalState.systemNavigationConfigurations?.configuration(for: type) {

                if let parentID = data.parentID ?? strongSelf.internalState.parentDestinationID {
                    configuration.parentDestinationID = parentID
                }

                if let actionTargetID = data.actionTargetID {
                    configuration.actionTargetID = actionTargetID
                }
                if let currentDestinationID = data.currentDestinationID {
                    configuration.currentDestinationID = currentDestinationID
                }
                
                if let model = data.contentType {
                    configuration.contentType = model
                }
                
                strongSelf.internalState.systemNavigationConfigurations?.configurations[type] = configuration
                
                presentationClosure(configuration)
            } else {
                DestinationsSupport.logger.log("System navigation closure could not be built for type \(type)", category: .error)
            }


        })
        
        container.eventType = navigationType
        container.data.presentationID = configuration.id
        container.data.destinationType = configuration.destinationType
        container.data.contentType = configuration.contentType
        container.data.actionType = configuration.actionType
        
        return container
    }

    func performAction(for eventType: EventType, content: ContentType? = nil) async -> Result<ContentType, Error> {

        if let presentation = internalState.destinationConfigurations?.configuration(for: eventType) {
            
            guard let interfaceAction = internalState.interfaceActions[eventType] else {
                let template = DestinationsSupport.errorMessage(for: .missingInterfaceAction(message: ""))
                let message = String(format: template, eventType.rawValue, type.rawValue)
                
                return .failure(DestinationsError.missingInterfaceAction(message: message))
            }
            
            let assistant: (any InterfaceActionConfiguring<EventType, DestinationType, ContentType>)
            
            switch presentation.assistantType {
                case .basic:
                    assistant = DefaultPresentationAssistant<EventType, DestinationType, ContentType>()
                case .custom(let customAssistant):
                    if let customAssistant = customAssistant as? any InterfaceActionConfiguring<EventType, DestinationType, ContentType> {
                        assistant = customAssistant
                    } else {
                        let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                        let message = String(format: template, self.type.rawValue)
                        return .failure(DestinationsError.missingInterfaceActionAssistant(message: message))
                    }
            }
            
            let configuredAction = assistant.configure(interfaceAction: interfaceAction, eventType: eventType, destination: self, content: content)
            configuredAction()
            
        } else if let configuration = internalState.destinationConfigurations?.interactorConfiguration(for: eventType) as? any InteractorConfiguring<InteractorType> {
            
            switch configuration.configurationType {
                case .interactor:
                    if let interactorType = configuration.interactorType, let actionType = configuration.actionType, let assistant = internalState.interactorAssistants[eventType] as? any AsyncInteractorAssisting<InteractorType, ContentType> {
                        
                        guard internalState.interactors[interactorType] as? any AsyncInteractable != nil else {
                            let template = DestinationsSupport.errorMessage(for: .interactorNotFound(message: ""))
                            let message = String(format: template, "\(String(describing: interactor))")
                            
                            return .failure(DestinationsError.interactorNotFound(message: message))
                        }
                        
                        return await assistant.asyncRequest(destination: self, actionType: actionType, content: content)
                    }
                    
                case .sequence, .group, .branch:
                    break
            }
            

        }
        
        // An interface action exists but no configuration was found for its event type, so
        // the most likely problem is a missing interactor configuration
        if internalState.interfaceActions[eventType] != nil {
            let template = DestinationsSupport.errorMessage(for: .interactorNotFound(message: ""))
            let message = String(format: template, eventType.rawValue)
            return .failure(DestinationsError.interactorNotFound(message: message))
        } else {
            let template = DestinationsSupport.errorMessage(for: .missingInterfaceAction(message: ""))
            let message = String(format: template, eventType.rawValue, type.rawValue)
            return .failure(DestinationsError.missingInterfaceAction(message: message))
        }
    }
    
    func performAction(for eventType: EventType, content: ContentType? = nil) throws {
        
        guard var interfaceAction = internalState.interfaceActions[eventType] else {
            let template = DestinationsSupport.errorMessage(for: .missingInterfaceAction(message: ""))
            let message = String(format: template, eventType.rawValue, type.rawValue)
            
            throw DestinationsError.missingInterfaceAction(message: message)
        }
        
        if let presentation = internalState.destinationConfigurations?.configuration(for: eventType) {
            
            let assistant: (any InterfaceActionConfiguring<EventType, DestinationType, ContentType>)
            
            switch presentation.assistantType {
                case .basic:
                    assistant = DefaultPresentationAssistant<EventType, DestinationType, ContentType>()
                case .custom(let customAssistant):
                    if let customAssistant = customAssistant as? any InterfaceActionConfiguring<EventType, DestinationType, ContentType> {
                        assistant = customAssistant
                    } else {
                        let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                        let message = String(format: template, self.type.rawValue)
                        throw DestinationsError.missingInterfaceActionAssistant(message: message)
                    }
            }
            
            let configuredAction = assistant.configure(interfaceAction: interfaceAction, eventType: eventType, destination: self, content: content)
            configuredAction()
            
        } else {
            // if no presentation was found, this is probably an action for an interactor
            interfaceAction.data.contentType = content
            interfaceAction()
        }
    }
    
    
    func performActions(configuration: any ActionCollectionConfiguring<InteractorType, ContentType>, content: ContentType? = nil) async -> Result<ActionCollectionResults<ContentType>, any Error> {
        return await buildAndRunActionCollection(configuration, content: content)
    }

    func performActions(for eventType: EventType, content: ContentType? = nil) async -> Result<ActionCollectionResults<ContentType>, any Error> {
        guard let configuration = internalState.destinationConfigurations?.interactorConfiguration(for: eventType) as? ActionSequenceConfiguration<InteractorType, ContentType> else {
            return .failure(DestinationsError.interactorNotFound(message: "No ActionSequence configuration found for \(eventType.rawValue)"))
        }
        
        switch configuration.configurationType {
            case .group, .sequence:
                return await buildAndRunActionCollection(configuration, content: content)

            case .branch, .interactor:
                if let interactorType = configuration.interactorType, let actionType = configuration.actionType, let assistant = internalState.interactorAssistants[eventType] as? any AsyncInteractorAssisting<InteractorType, ContentType> {
                    
                    guard internalState.interactors[interactorType] as? any AsyncInteractable != nil else {
                        let template = DestinationsSupport.errorMessage(for: .interactorNotFound(message: ""))
                        let message = String(format: template, "\(String(describing: interactor))")
                        
                        return .failure(DestinationsError.interactorNotFound(message: message))
                    }
                    
                    let result = await assistant.asyncRequest(destination: self, actionType: actionType, content: content)
                    
                    switch result {
                        case .success(_):
                            let actionResult = ActionResult(origin: .action(actionType), result: result)
                            return .success(ActionCollectionResults(results: [actionResult]))
                        case .failure(let error):
                            return .failure(error)
                    }
                    
                } else {
                    return .failure(DestinationsError.missingInterfaceActionAssistant(message: "Expected assistant for event \(eventType)"))

                }
        }
        
    }

    internal func buildAndRunActionCollection(_ configuration: any ActionCollectionConfiguring<InteractorType, ContentType>, content: ContentType?) async -> Result<ActionCollectionResults<ContentType>, any Error> {

        guard configuration.actions.count > 0 else {
            return .failure(ActionError<ContentType>.noActionsAvailable)
        }

        // run preflight checks to make sure all Interactors used in each action have been added to this Destination
        let missingTypes = Set(
            configuration.actions
                .flatMap { collectRequiredInteractorTypes(from: $0) }
                .filter { interactor(for: $0) == nil }
        )
        guard missingTypes.isEmpty else {
            let names = missingTypes.map { "\($0)" }.sorted().joined(separator: ", ")
            let errorMessage = "Action sequence references unregistered interactor type(s): \(names). Assign them via assignInteractor(_:to:) before calling performActions."
            let template = DestinationsSupport.errorMessage(for: .unregisteredInteractor(message: errorMessage))
            let message = String(format: template, names)
            
            return .failure(DestinationsError.unregisteredInteractor(message: message))
        }

        var collection: any ActionPerformableCollection<ContentType>
        
        switch configuration.configurationType {
            case .sequence:
                collection = ActionSequence<ContentType>(identifier: configuration.identifier, outputConduit: configuration.outputConduit, shouldEndParentTaskOnFailure: configuration.shouldEndParentTaskOnFailure, shouldSaveResult: configuration.shouldSaveResult)
                
            case .group:
                guard let merger = configuration.merger else {
                    return .failure(ActionError<ContentType>.invalidConfiguration)
                }
                collection = ActionGroup(merger: merger, identifier: configuration.identifier, outputConduit: configuration.outputConduit, shouldEndParentTaskOnFailure: configuration.shouldEndParentTaskOnFailure, shouldSaveResult: configuration.shouldSaveResult, shouldSaveChildResults: configuration.shouldSaveChildResults)
                
            case .branch, .interactor:
                return .failure(ActionError<ContentType>.notActionConfiguration)
        }
        
        for actionConfiguration in configuration.actions {
            do {
                let action = try actionConfiguration.buildAction(resultHandler: self)
                try collection.add(action: action)
            } catch {
                return .failure(error)
            }
        }

        // The sequence runs in an unstructured Task so it can be cancelled externally via `cancelActionSequence(for:)`, but cancellation of the caller's context still propagates to it.
        let task = Task { [collection] in
            await collection.perform(with: content, sequenceOutputs: ActionCollectionResults<ContentType>())
        }
        
        internalState.activeSequenceTasks[collection.id] = task
        defer { internalState.activeSequenceTasks[collection.id] = nil }
        
        return await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }

    func cancelAllActionSequences() {
        for task in internalState.activeSequenceTasks.values {
            task.cancel()
        }
    }

    /// Recursively collects all ``InteractorType`` values referenced by leaf ``ActionConfiguration`` nodes
    /// in a configuration tree, walking into nested sequences, groups, and branch paths.
    internal func collectRequiredInteractorTypes(from config: any ActionConfiguring<InteractorType, ContentType>) -> [InteractorType] {
        if let branch = config as? ActionBranchConfiguration<InteractorType, ContentType> {
            return branch.cases.flatMap { collectRequiredInteractorTypes(from: $0.actionConfig) }
        }
        if let collection = config as? any ActionCollectionConfiguring<InteractorType, ContentType> {
            return collection.actions.flatMap { collectRequiredInteractorTypes(from: $0) }
        }
        if let type = config.interactorType {
            return [type]
        }
        return []
    }

    @available(*, deprecated, renamed: "performAction(for:content:)", message: "This method is deprecated and will be removed in a future version. Please migrate your code to use the `performAction(for:content:)` method instead.")
    func performInterfaceAction(eventType: EventType, content: ContentType? = nil) throws {
        try performAction(for: eventType, content: content)
    }
    
    func interactor(for type: InteractorType) -> (any AbstractInteractable)? {
        return internalState.interactors[type]
    }
    
    func addInterfaceAction(action: InterfaceAction<EventType, DestinationType, ContentType>) throws {
        guard let type = action.eventType else { return }
        
        if internalState.interfaceActions.keys.firstIndex(of: type) == nil {
            internalState.interfaceActions[type] = action
            
        } else {
            let template = DestinationsSupport.errorMessage(for: .duplicateEventTypeUsed(message: ""))
            let message = String(format: template, type.rawValue)
            
            throw DestinationsError.duplicateEventTypeUsed(message: message)
        }

    }
    
    func addSystemNavigationAction(action: InterfaceAction<SystemNavigationType, DestinationType, ContentType>) {
        
        if let type = action.eventType {
            internalState.systemNavigationActions[type] = action
        }
    }
    
    func assignInteractorAssistant(assistant: any InteractorAssisting<InteractorType, ContentType>, for eventType: EventType) {
        internalState.interactorAssistants[eventType] = assistant
    }
    
    func performSystemNavigationAction<T>(navigationType: SystemNavigationType, options: T?) {
        
        if var closure = internalState.systemNavigationActions[navigationType] {
            
            switch navigationType {
                case .navigateBackInStack:
                    closure.data.currentDestinationID = self.id
                    if let options = options as? SystemNavigationOptions {
                        closure.data.actionTargetID = options.targetID
                    } else {
                        closure.data.actionTargetID = self.id
                    }
                    closure.data.parentID = self.id
                    
                    closure.data.presentationType = DestinationPresentationType<DestinationType, ContentType, TabType>.navigationStack(type: .goBack)

                case .dismissSheet:
                    closure.data.currentDestinationID = self.id
                    closure.data.parentID = self.id
                    if let options = options as? SystemNavigationOptions {
                        closure.data.actionTargetID = options.targetID
                        if let currentID = options.currentID {
                            closure.data.currentDestinationID = currentID
                        }
                        if let parentID = options.parentID {
                            closure.data.parentID = parentID
                        }
                    }

            }
            
            internalState.isSystemNavigating = true

            closure()
        }
    }
    
#if swift(>=6.1)
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<Request.ResultData, Error> {
        
        guard let interactor = internalState.interactors[interactor] as? any AsyncInteractable<Request> else {
            let template = DestinationsSupport.errorMessage(for: .interactorNotFound(message: ""))
            let message = String(format: template, "\(interactor)")
            
            return .failure(DestinationsError.interactorNotFound(message: message))
        }
        
        return await interactor.perform(request: request)

    }
#else
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<Request.ResultData, Error> {
        
        guard let interactor = internalState.interactors[interactor] as? any AsyncInteractable<Request, Request.ResultData> else {
            let template = DestinationsSupport.errorMessage(for: .interactorNotFound(message: ""))
            let message = String(format: template, "\(interactor)")
            
            return .failure(DestinationsError.interactorNotFound(message: message))
        }
        
        return await interactor.perform(request: request)

    }
#endif
    
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) {
        
        guard let interactor = internalState.interactors[interactor] as? any Interactable<Request> else {
            let template = DestinationsSupport.errorMessage(for: .interactorNotFound(message: ""))
            let message = String(format: template, "\(interactor)")
            DestinationsSupport.logger.log(message)
            
            return
        }
        
        interactor.perform(request: request)

    }
    
    func isSystemNavigating() -> Bool {
        return internalState.isSystemNavigating
    }
    
    func updateIsSystemNavigating(isNavigating: Bool) {
        internalState.isSystemNavigating = isNavigating
    }
    
    func parentDestinationID() -> UUID? {
        return internalState.parentDestinationID
    }
    
    // default implementation
    func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) {
        stateModel?.handleInteractorResult(result: result, for: request)
    }
    
    // default implementation
    func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async {
        await stateModel?.handleAsyncInteractorResult(result: result, for: request)
    }
    
    /// A description of this object.
    var description: String {
        return "\(Self.self) : \(type) : \(id)"
    }
    
    // MARK: AssistantAssigning protocol conformance
    
    @discardableResult
    func tryAssignInteractorAssistant(_ assistant: any Sendable, for eventType: any Hashable) -> Bool {
        guard let assistant = assistant as? any InteractorAssisting<InteractorType, ContentType>,
              let eventType = eventType as? EventType else {
            return false
        }
        assignInteractorAssistant(assistant: assistant, for: eventType)
        return true
    }
}


public extension Destinationable {
    
    func handleThrowable(closure: @escaping () throws -> Void, catchClosure: (() -> Void)? = nil) {
        do {
            try closure()
            
        } catch DestinationsError.tabNotFound(message: let message),
                DestinationsError.interactorNotFound(message: let message),
                DestinationsError.unsupportedInteractorActionType(message: let message),
                DestinationsError.missingInterfaceAction(message: let message),
                DestinationsError.missingInterfaceActionAssistant(message: let message),
                DestinationsError.duplicateEventTypeUsed(message: let message)
        {
            DestinationsSupport.logger.log(message, category: .error)
            catchClosure?()

        } catch {
            DestinationsSupport.logger.log("\(error.localizedDescription)", category: .error)
            catchClosure?()
        }
    }
    
    func logError(error: Error) {
        DestinationsSupport.logError(error: error)
    }
}
