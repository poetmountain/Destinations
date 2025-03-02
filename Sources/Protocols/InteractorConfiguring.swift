//
//  InteractorConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a model which configures how an interactor is used with a Destination.
@MainActor public protocol InteractorConfiguring<InteractorType> {
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    associatedtype Interactor: AbstractInteractable
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: InteractorRequestActionTypeable
    
    /// The type of interactor.
    var interactorType: InteractorType { get }
    
    /// The type of interactor request action.
    var actionType: ActionType { get }
    
    /// The type of interactor assistant associated with the interactor to be configured.
    var assistantType: InteractorAssistantType { get }
    
    /// Assigns an interactor assistant to a Destination.
    /// - Parameters:
    ///   - destination: The Destination to apply this interactor assistant to.
    ///   - interactionType: The user interaction type to associate this assistant with.
    func assignInteractorAssistant<Destination: Destinationable>(destination: Destination, interactionType: Destination.UserInteractionType) where InteractorType == Destination.InteractorType
}
