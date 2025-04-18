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
}

public extension ControllerDestinationable {
    
    func assignInteractor<Request: InteractorRequestConfiguring>(interactor: any AbstractInteractable<Request>, for type: InteractorType) {
    
        internalState.interactors[type] = interactor
        
        configureInteractor(interactor, type: type)

    }
    
    func currentController() -> ControllerType? {
        return controller
    }
    
    func updateInterfaceActions(actions: [InterfaceAction<UserInteractionType, DestinationType, ContentType>]) {
        for action in actions {
            if let action = action as? InterfaceAction<UserInteractionType, DestinationType, ContentType>, let interactionType = action.userInteractionType {
                handleThrowable { [weak self] in
                    try self?.addInterfaceAction(action: action)
                }
            }
        }

    }
    
    func updateSystemNavigationActions(actions: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>]) {
        for action in actions {
            if let action = action as? InterfaceAction<SystemNavigationType, DestinationType, ContentType>, let interactionType = action.userInteractionType {
                addSystemNavigationAction(action: action)
            }
        }

    }
    
    func assignAssociatedController(controller: ControllerType) {
        self.controller = controller
    }
    
    func removeAssociatedInterface() {
        controller = nil
    }

}


