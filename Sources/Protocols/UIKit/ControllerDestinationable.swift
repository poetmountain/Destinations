//
//  ControllerDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This protocol represents a Destination which is associated with a `UIViewController`.
@MainActor public protocol ControllerDestinationable<DestinationType, ContentType, TabType>: Destinationable {
    
    /// The type of view controller associated with this Destination.
    associatedtype ControllerType: ControllerDestinationInterfacing

    /// The `UIViewController` associated with this Destination.
    var controller: ControllerType? { get set }
    
    /// Returns the controller this Destination manages.
    func currentController() -> ControllerType?

    /// Assigns a `UIViewController` instance to be associated with this Destination.
    /// - Parameter controller: The `UIViewController` that should be represented by this Destination.
    func assignAssociatedController(controller: ControllerType)
    
    /// Sets a reference to the navigator presenting this Destination.
    /// - Parameter navigator: A navigator object.
    func setPresentingNavigator(navigator: any DestinationPathNavigating)
    
    /// Requests that the navigator presenting this Destination move to the previous Destination in the navigation path.
    func moveBackInNavigationStack()
    
}

public extension ControllerDestinationable {
    
    @available(*, deprecated, renamed: "assignInteractor(_:to:)", message: "This method is deprecated and will be removed in a future version. Please migrate your code to use the `assignInteractor(_:to:)` method instead.")
    func assignInteractor<Request: InteractorRequestConfiguring>(interactor: any AbstractInteractable<Request>, for type: InteractorType) {
    
        internalState.interactors[type] = interactor
        
        configureInteractor(interactor, type: type)

    }
    
    func assignInteractor<Request: InteractorRequestConfiguring>(_ interactor: any AbstractInteractable<Request>, to type: InteractorType) {
        
        internalState.interactors[type] = interactor
        configureInteractor(interactor, type: type)
        
    }
    
    func currentController() -> ControllerType? {
        return controller
    }
    
    func updateInterfaceActions(actions: [InterfaceAction<EventType, DestinationType, ContentType>]) {
        for action in actions {
            if action.eventType != nil {
                handleThrowable { [weak self] in
                    try self?.addInterfaceAction(action: action)
                }
            }
        }

    }
    
    func updateSystemNavigationActions(actions: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>]) {
        for action in actions {
            if action.eventType != nil {
                addSystemNavigationAction(action: action)
            }
        }

    }
    
    func assignAssociatedController(controller: ControllerType) {
        self.controller = controller
        
        // assign the state from the view controller to the Destination
        if let viewModel = controller.destinationState.stateModel as? any StateModeling<Self> {
            self.stateModel = viewModel
            self.stateModel?.destination = self
        } else {
            assertionFailure("The StateModel assigned to the view controller's destinationState is not of type StateModeling.")
        }
    }
    
    func removeAssociatedInterface() {
        controller = nil
        stateModel?.destination = nil
        stateModel = nil
    }
    
    func setPresentingNavigator(navigator: any DestinationPathNavigating) {
        internalState.navigator = navigator
    }

    func moveBackInNavigationStack() {
        guard let navigator = internalState.navigator else {
            DestinationsSupport.logger.log("Attempted to navigate back in stack, but no containing navigator was found.", category: .error, level: .error)
            return
        }
        
        var options: SystemNavigationOptions?
        if let targetID = navigator.previousPathElement() {
            options = SystemNavigationOptions(targetID: targetID)
        } else if let parentID = parentDestinationID() {
            options = SystemNavigationOptions(targetID: parentID)
        } else {
            options = SystemNavigationOptions(targetID: self.id)
        }
        
        performSystemNavigationAction(navigationType: SystemNavigationType.navigateBackInStack, options: options)
    }
}


