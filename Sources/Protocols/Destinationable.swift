//
//  Destinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a Destination in the Destinations ecosystem.
///
/// A Destination represents a unique area in an app which can be navigated to by the user. In SwiftUI this is typically a fullscreen `View` object, and in UIKit it's a `UIViewController` class or subclass, but it can also be a group of Destinations like a `TabBar` or a carousel. Destinations hold references to the UI element they're associated with, but they don't handle the particulars of laying out elements on the screen. Instead, the role of Destination objects in the ecosystem is to send and receive messages and datasource requests on behalf of their UI, such as passing on a message to trigger an action when a user taps a button.
///
/// In most cases you should be able to use the provided `ViewDestination` or `ControllerDestination` classes for SwiftUI or UIKit apps respectively. They are customized to a particular Destination through generic arguments.  To handle presentation requests that require specialized configuration or need to handle content models, you can create custom assistants which conform to the `InterfaceActionConfiguring` protocol. To handle requests to an interactor, you can create assistants which conform to the `InteractorAssisting` protocol. There are more specific classes to support interfaces like TabBars, but you can also use your own Destination classes by conforming to `ViewDestinationable` or `ControllerDestinationable` if you should need custom functionality or just want to avoid using generics.
///
/// There is a two-way connection between a Destination and its interface which is handled by a `DestinationStateable`-conforming object. Destinations comes with a `DestinationInterfaceState` object which can be used for this purpose, though you can create your own class if you'd like to store other state in it. When a Destination is removed from the ecosystem, cleanup is done internally to ensure no retain cycles occur.
@MainActor public protocol Destinationable<PresentationConfiguration>: AnyObject, Identifiable {
    
    /// An enum which defines user interaction types for this Destination's interface.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring<DestinationType, TabType, ContentType>
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    
    /// A type of ``AppDestinationConfigurations`` which handles system navigation events.
    typealias NavigationConfigurations = AppDestinationConfigurations<SystemNavigationType, PresentationConfiguration>
    
    /// The unique identifier for this Destination.
    var id: UUID { get }

    /// This enum value conforming to ``RoutableDestinations`` represents a specific Destination type.
    var type: DestinationType { get }
    
    /// The identifier of this object's parent Destination.
    var parentDestinationID: UUID? { get set }
    
    /// An ``AppDestinationConfigurations`` object representing configurations to handle user interactions on this Destination's associated UI.
    var destinationConfigurations: DestinationConfigurations? { get set }
    
    /// An ``AppDestinationConfigurations`` instance that holds configurations to handle system navigation events related to this Destination.
    var systemNavigationConfigurations: NavigationConfigurations? { get set }

    /// A Boolean that denotes whether the UI is currently in a navigation transition.
    var isSystemNavigating: Bool { get set }

    /// A dictionary of interactors, with the associated keys being their interactor type.
    var interactors: [InteractorType: any Interactable] { get set }
    
    /// A dictionary of ``InterfaceAction`` objects, with the key being the associated user interaction type.
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] { get set }
    
    /// A dictionary of system navigation interface actions which are run when certain system navigation events occur, with the key being the associated system navigation type.
    var systemNavigationActions: [SystemNavigationType: InterfaceAction<SystemNavigationType, DestinationType, ContentType>] { get set }
    
    /// A dictionary of assistants which help the Destination make requests of an interactor, with the key being the associated user interaction type.
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<Self>] { get set }

    
    /// Performs the interface action associated with the specified user interaction type.
    /// - Parameter interactionType: The user interaction type whose action should be run.
    /// - Parameter content: Optional content to use with the interface action.
    func performInterfaceAction(interactionType: UserInteractionType, content: ContentType?) throws
    
    /// Builds the ``InterfaceAction`` objects to handle Destination presentations generated by this Destination. This should be called when configuring a Destination for presentation, typically from a ``Flowable`` object.
    /// - Parameter presentationClosure: The presentation closure to be used in building the ``InterfaceAction`` objects.
    func buildInterfaceActions(presentationClosure: @escaping (_ configuration: PresentationConfiguration) -> Void)
    
    /// Builds an ``InterfaceAction`` object to handle the specified Destination presentation.
    /// - Parameters:
    ///   - presentationClosure: A presentation closure to be used in building the ``InterfaceAction`` object.
    ///   - configuration: A model object used to configure the presentation.
    ///   - interactionType: The user interaction type associated with this presentation.
    /// - Returns: An ``InterfaceAction`` object for this presentation.
    func buildInterfaceAction(presentationClosure: @escaping (DestinationConfigurations.PresentationConfiguration) -> Void, configuration: DestinationConfigurations.PresentationConfiguration, interactionType: UserInteractionType) -> InterfaceAction<UserInteractionType, DestinationType, ContentType>
    
    /// Builds the ``InterfaceAction`` objects to handle requests for this Destination's interactors.
    /// - Parameter presentationClosure: The presentation configuration object closure. Currently this is unused.
    func buildInteractorActions(presentationClosure: @escaping (_ configuration: PresentationConfiguration) -> Void)

    /// Updates the interface actions associated with this Destination.
    /// - Parameter closures: An array of ``InterfaceAction`` objects containing user interaction closures to be run.
    func updateInterfaceActions(actions: [InterfaceAction<UserInteractionType, DestinationType, ContentType>])
    
    /// Builds the system navigation actions. This should be called when configuring a Destination for presentation, typically from a ``Flowable`` object.
    /// - Parameter presentationClosure: A closure passing in a presentation configuration object to be used in building the system navigation closures.
    func buildSystemNavigationActions(presentationClosure: @escaping (PresentationConfiguration) -> Void)
    
    /// Builds a system navigation action.
    /// - Parameters:
    ///   - presentationClosure: A closure which helps build the associated ``InterfaceAction``.
    ///   - configuration: A model object which helps configure the system navigation action.
    ///   - navigationType: The type of system navigation event associated with this action.
    /// - Returns: An ``InterfaceAction`` object for this system event.
    func buildSystemNavigationAction(presentationClosure: @escaping (DestinationConfigurations.PresentationConfiguration) -> Void, configuration: DestinationConfigurations.PresentationConfiguration, navigationType: SystemNavigationType) -> InterfaceAction<SystemNavigationType, DestinationType, ContentType>
    
    /// Updates the system navigation closures associated with this Destination.
    /// - Parameter closures: An array of ``InterfaceAction`` objects containing system navigation closures to be run.
    func updateSystemNavigationActions(actions: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>])

    /// Returns a presentation configuration object based on its identifier.
    /// - Parameter presentationID: The identifier of a presentation configuration object.
    /// - Returns: The configuration object, or `nil` if the specified object was not found.
    func presentation(presentationID: UUID) -> (PresentationConfiguration)?
    
    /// Returns a system navigation configuration object based on its identifier.
    /// - Parameter presentationID: The identifier of a presentation configuration object.
    /// - Returns: The system navigation configuration object, if one was found.
    func systemNavigationPresentation(presentationID: UUID) -> (PresentationConfiguration)?
    
    /// Returns a presentation configuration object based on its associated user interaction type.
    /// - Parameter interactionType: The user interaction type.
    /// - Returns: The configuration object, or `nil` if the specified object was not found.
    func presentation(for interactionType: UserInteractionType) -> (PresentationConfiguration)?
    
    /// Returns a system navigation configuration object based on its associated type.
    /// - Parameter navigationType: The system navigation type.
    /// - Returns: The configuration object, or `nil` if the specified object was not found.
    func systemNavigationPresentation(for navigationType: SystemNavigationType) -> (PresentationConfiguration)?
    
    /// Updates an existing presentation with a new configuration object. If no presentation is found which matches this object's identifier, nothing is updated.
    /// - Parameter presentation: The presentation configuration object to replace an existing one.
    func updatePresentation(presentation: PresentationConfiguration)
    
    /// Updates an existing system navigation presentation with a new configuration object. If no system navigation object is found which matches this object's identifier, nothing is updated.
    /// - Parameter presentation: The presentation configuration object to replace an existing one.
    func updateSystemNavigationPresentation(presentation: PresentationConfiguration)
    
    /// Adds setup functionality for an interactor, which will add and register it with this Destination. An interactor handles specialized tasks and interactions with other APIs for the Destination.
    /// - Parameters:
    ///   - interactor: The interactor to add.
    ///   - type: Specifies the type of interactor, which will be used to look up the interactor.
    func setupInteractor<Request: InteractorRequestConfiguring, ResultData: Hashable>(interactor: any Interactable<Request, ResultData>, for type: InteractorType)
    
    /// Returns an interactor for the specified type.
    /// - Parameter type: The type of interactor.
    /// - Returns: An interactor, if one was found.
    func interactor(for type: InteractorType) -> (any Interactable)?
    
    /// Configures the interactor that is assigned to this Destination. You may use this method to make any initial requests to the interactor to set up the interface's initial state. This method is called automatically when an interactor is assigned to it.
    /// - Parameters:
    ///   - interactor: The interactor to configure requests for.
    ///   - type: The type of interactor.
    func configureInteractor(_ interactor: any Interactable, type: InteractorType)
    
    /// Adds an interface action.
    /// - Parameters:
    ///   - closure: The closure to add.
    func addInterfaceAction(action: InterfaceAction<UserInteractionType, DestinationType, ContentType>) throws
    
    /// Adds a system navigation closure.
    /// - Parameters:
    ///   - closure: The closure to add.
    func addSystemNavigationAction(action: InterfaceAction<SystemNavigationType, DestinationType, ContentType>)
    
    /// Assigns an interactor assistant to a specific type of user interaction.
    /// - Parameters:
    ///   - assistant: The interactor assistant to add.
    ///   - interactionType: The type of user interaction which this assistant should handle requests for.
    func assignInteractorAssistant(assistant: any InteractorAssisting<Self>, for interactionType: UserInteractionType)

    /// Performs a request with the specified interactor.
    /// - Parameters:
    ///   - interactor: The type of interactor that should receive the request.
    ///   - request: A model that defines the request.
    ///   - completionClosure: A closure to be run with the interactor request is completed.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request, completionClosure: DatasourceResponseClosure<[Request.ResultData]>?)
    
    /// Performs a request with the specified interactor asynchronously.
    /// - Parameters:
    ///   - interactor: The type of interactor that should receive the request.
    ///   - request: A model that defines the request.
    /// - Returns: A `Result` containing an array of items.
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<[Request.ResultData], Error>
    
    /// Performs a system navigation action, executing the closure associated with the provided system navigation type.
    /// - Parameters:
    ///   - navigationType: The type of system navigation event to perform.
    ///   - options: An optional options object for use with the closure.
    func performSystemNavigationAction<T>(navigationType: SystemNavigationType, options: T?)
    
    /// When this method is called, the Destination is about to be removed from the Flow. Any resource references should be removed and in-progress interactor tasks should be stopped.
    func cleanupResources()
    
    /// Removes the associated interface from this Destination. This method is called automatically when a Destination is removed in order to avoid a retain cycle.
    func removeAssociatedInterface()
    
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
    
    func cleanupResources() {
    }
    
    func presentation(presentationID: UUID) -> (PresentationConfiguration)? {
       return destinationConfigurations?.configurations.values.first { $0.id == presentationID }
    }
    
    func systemNavigationPresentation(presentationID: UUID) -> (PresentationConfiguration)? {
       return systemNavigationConfigurations?.configurations.values.first { $0.id == presentationID }
    }
    
    func systemNavigationPresentation(for navigationType: SystemNavigationType) -> (PresentationConfiguration)? {
        return systemNavigationConfigurations?.configurations[navigationType]
    }
    
    func presentation(for interactionType: UserInteractionType) -> (PresentationConfiguration)? {
        do {
            return try destinationConfigurations?.configuration(for: interactionType)
        } catch {
            return nil
        }
    }
    
    func configureInteractor(_ interactor: any Interactable, type: InteractorType) {}
    
    func updatePresentation(presentation: PresentationConfiguration) {
        guard var destinationConfigurations else { return }

        for (type, configuration) in destinationConfigurations.configurations {
            
            if configuration.id == presentation.id {
                self.destinationConfigurations?.configurations[type] = presentation
                break
            }
        }
    }
    
    func updateSystemNavigationPresentation(presentation: PresentationConfiguration) {
        guard var systemNavigationConfigurations else { return }

        for (type, configuration) in systemNavigationConfigurations.configurations {
            
            if configuration.id == presentation.id {
                self.systemNavigationConfigurations?.configurations[type] = presentation
                break
            }
        }
    }

    
    func buildInterfaceActions(presentationClosure: @escaping (PresentationConfiguration) -> Void) {

        guard let destinationConfigurations = destinationConfigurations else { return }

        var containers: [InterfaceAction<UserInteractionType, DestinationType, PresentationConfiguration.ContentType>] = []
        for (type, configuration) in destinationConfigurations.configurations {
            let container = buildInterfaceAction(presentationClosure: presentationClosure, configuration: configuration, interactionType: type)
            containers.append(container)
        }
        
        updateInterfaceActions(actions: containers)
        
    }
    
    func buildInterfaceAction(presentationClosure: @escaping (DestinationConfigurations.PresentationConfiguration) -> Void, configuration: DestinationConfigurations.PresentationConfiguration, interactionType: UserInteractionType) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {

        var container = InterfaceAction<UserInteractionType, DestinationType, ContentType>(function: { [weak self] (type: UserInteractionType, data: InterfaceActionData<DestinationType, ContentType>) in
            guard let strongSelf = self else { return }
            
            if var configuration = strongSelf.destinationConfigurations?.configuration(for: type) {
                if let parentID = data.parentID ?? strongSelf.parentDestinationID {
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
                
                strongSelf.destinationConfigurations?.configurations[type] = configuration
                
                presentationClosure(configuration)
            } else {
                DestinationsOptions.logger.log("Interface action closure could not be built for type \(type)", category: .error)
            }

        })
        
        container.userInteractionType = interactionType
        container.data.presentationID = configuration.id
        container.data.destinationType = configuration.destinationType
        container.data.contentType = configuration.contentType
        container.data.actionType = configuration.actionType
        
        return container
    }
    
    func buildInteractorActions(presentationClosure: @escaping (PresentationConfiguration) -> Void) {

        var containers: [InterfaceAction<UserInteractionType, DestinationType, PresentationConfiguration.ContentType>] = []
        for (type, _) in interactorAssistants {
            let container = buildInteractorAction(presentationClosure: presentationClosure, interactionType: type)
            containers.append(container)
        }
        
        updateInterfaceActions(actions: containers)
        
    }
        
    internal func buildInteractorAction(presentationClosure: @escaping (DestinationConfigurations.PresentationConfiguration) -> Void, interactionType: UserInteractionType) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {

        var container = InterfaceAction<UserInteractionType, DestinationType, ContentType>(function: { [weak self] (type: UserInteractionType, data: InterfaceActionData<DestinationType, ContentType>) in
            guard let strongSelf = self else { return }
            
            if let assistant = strongSelf.interactorAssistants[interactionType] {
                
                switch assistant.requestMethod {
                    case .async:
                        Task {
                            await assistant.handleAsyncRequest(destination: strongSelf)
                        }
                    case .sync:
                        assistant.handleRequest(destination: strongSelf)
                }
                
                
            } else {
                let template = DestinationsOptions.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                let message = String(format: template, type.rawValue)
                strongSelf.logError(error: DestinationsError.missingInterfaceActionAssistant(message: message))
            }

        })
        
        container.userInteractionType = interactionType

        return container
    }
    

    func buildSystemNavigationActions(presentationClosure: @escaping (PresentationConfiguration) -> Void) {

        guard let systemNavigationConfigurations else { return }

        var containers: [InterfaceAction<SystemNavigationType, DestinationType, PresentationConfiguration.ContentType>] = []
        for (type, configuration) in systemNavigationConfigurations.configurations {
            if let container = buildSystemNavigationAction(presentationClosure: presentationClosure, configuration: configuration, navigationType: type) as? InterfaceAction<SystemNavigationType, DestinationType, ContentType> {
                containers.append(container)
            }
        }
        
        updateSystemNavigationActions(actions: containers)
        
    }
    
    func buildSystemNavigationAction(presentationClosure: @escaping (DestinationConfigurations.PresentationConfiguration) -> Void, configuration: DestinationConfigurations.PresentationConfiguration, navigationType: SystemNavigationType) -> InterfaceAction<SystemNavigationType, DestinationType, ContentType> {

        var container = InterfaceAction<SystemNavigationType, DestinationType, PresentationConfiguration.ContentType>(function: { [weak self] (type: SystemNavigationType, data: InterfaceActionData<DestinationType, PresentationConfiguration.ContentType>) in
            guard let strongSelf = self else { return }
            

            if var configuration = strongSelf.systemNavigationConfigurations?.configuration(for: type) {

                if let parentID = data.parentID ?? strongSelf.parentDestinationID {
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
                
                strongSelf.systemNavigationConfigurations?.configurations[type] = configuration
                
                presentationClosure(configuration)
            } else {
                DestinationsOptions.logger.log("System navigation closure could not be built for type \(type)", category: .error)
            }


        })
        
        container.userInteractionType = navigationType
        container.data.presentationID = configuration.id
        container.data.destinationType = configuration.destinationType
        container.data.contentType = configuration.contentType
        container.data.actionType = configuration.actionType
        
        return container
    }

    func performInterfaceAction(interactionType: UserInteractionType, content: ContentType? = nil) throws {
        
        guard var interfaceAction = interfaceActions[interactionType] else {
            let template = DestinationsOptions.errorMessage(for: .missingInterfaceAction(message: ""))
            let message = String(format: template, interactionType.rawValue, type.rawValue)
            
            throw DestinationsError.missingInterfaceAction(message: message)
        }
        
        if let presentation = destinationConfigurations?.configuration(for: interactionType) {
            
            let assistant: (any InterfaceActionConfiguring<UserInteractionType, DestinationType, ContentType>)
            
            switch presentation.assistantType {
                case .basic:
                    assistant = DefaultActionAssistant<UserInteractionType, DestinationType, ContentType>()
                case .custom(let customAssistant):
                    if let customAssistant = customAssistant as? any InterfaceActionConfiguring<UserInteractionType, DestinationType, ContentType> {
                        assistant = customAssistant
                    } else {
                        let template = DestinationsOptions.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                        let message = String(format: template, self.type.rawValue)
                        throw DestinationsError.missingInterfaceActionAssistant(message: message)
                    }
            }
            
            let configuredAction = assistant.configure(interfaceAction: interfaceAction, interactionType: interactionType, destination: self, content: content)
            configuredAction()
            
        } else {
            // if no presentation was found, this is probably an action for an interactor
            interfaceAction()
        }
    }
    
    func interactor(for type: InteractorType) -> (any Interactable)? {
        return interactors[type]
    }
    
    func addInterfaceAction(action: InterfaceAction<UserInteractionType, DestinationType, ContentType>) throws {
        guard let type = action.userInteractionType else { return }
        
        if interfaceActions.keys.firstIndex(of: type) == nil {
            interfaceActions[type] = action
            
        } else {
            let template = DestinationsOptions.errorMessage(for: .duplicateUserInteractionTypeUsed(message: ""))
            let message = String(format: template, type.rawValue)
            
            throw DestinationsError.duplicateUserInteractionTypeUsed(message: message)
        }

    }
    
    func addSystemNavigationAction(action: InterfaceAction<SystemNavigationType, DestinationType, ContentType>) {
        
        if let type = action.userInteractionType {
            systemNavigationActions[type] = action
        }
    }
    
    func assignInteractorAssistant(assistant: any InteractorAssisting<Self>, for interactionType: UserInteractionType) {
        interactorAssistants[interactionType] = assistant
    }
    
    func performSystemNavigationAction<T>(navigationType: SystemNavigationType, options: T?) {
        
        if var closure = systemNavigationActions[navigationType] {
            
            switch navigationType {
                case .navigateBackInStack:
                    closure.data.currentDestinationID = self.id
                    if let options = options as? SystemNavigationOptions {
                        closure.data.actionTargetID = options.targetID
                    } else {
                        closure.data.actionTargetID = self.id
                    }
                    closure.data.parentID = self.id

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
            
            isSystemNavigating = true

            closure()
        }
    }
    
    
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request) async -> Result<[Request.ResultData], Error> {
        
        guard let interactor = interactors[interactor] as? any AsyncInteractable<Request, Request.ResultData> else {
            let template = DestinationsOptions.errorMessage(for: .interactorNotFound(message: ""))
            let message = String(format: template, "\(interactor)")
            
            return .failure(DestinationsError.interactorNotFound(message: message))
        }
        
        return await interactor.perform(request: request)

    }
    
    
    func performRequest<Request: InteractorRequestConfiguring>(interactor: InteractorType, request: Request, completionClosure: DatasourceResponseClosure<[Request.ResultData]>?) {
        
        guard let interactor = interactors[interactor] as? any Interactable<Request, Request.ResultData> else {
            let template = DestinationsOptions.errorMessage(for: .interactorNotFound(message: ""))
            let message = String(format: template, "\(interactor)")
            
            completionClosure?(.failure(DestinationsError.interactorNotFound(message: message)))
            return
        }
        
        Task {
            await interactor.perform(request: request, completionClosure: completionClosure)
        }
    }
    
    /// A description of this object.
    var description: String {
        return "\(Self.self) : \(type) : \(id)"
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
                DestinationsError.duplicateUserInteractionTypeUsed(message: let message)
        {
            DestinationsOptions.logger.log(message, category: .error)
            catchClosure?()

        } catch {
            DestinationsOptions.logger.log("\(error.localizedDescription)", category: .error)
            catchClosure?()
        }
    }
    
    func logError(error: Error) {
        DestinationsOptions.logError(error: error)
    }
}
