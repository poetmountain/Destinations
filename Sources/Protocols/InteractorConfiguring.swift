//
//  InteractorConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Represents the type of action to be configured.
public enum ActionConfigurationType {
    case interactor
    case sequence
    case group
    case branch
}

/// This protocol represents a configuration for a specific action an Interactor should take.
@MainActor public protocol InteractorConfiguring<InteractorType> {
    
    /// An enum which represents types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable

    /// An enum type representing the kind of interactor to be configured.
    var interactorType: InteractorType? { get }

    /// An enum type representing the type of interactor request action.
    var actionType: (any InteractorRequestActionTypeable)? { get }
    
    /// The type of interactor assistant associated with the interactor to be configured.
    var assistantType: InteractorAssistantType? { get }
    
    /// Represents the type of action this object should configure.
    var configurationType: ActionConfigurationType { get }
    
    /// Assigns an interactor assistant to a Destination, dispatched through a type-erased channel.
    ///
    /// The destination performs a runtime check to ensure its `InteractorType`/`ContentType`
    /// and `EventType` are compatible with this configuration's assistant before assignment.
    /// - Parameters:
    ///   - assignable: The destination (as an erased `AssistantAssigning`) to apply this assistant to.
    ///   - eventType: The event type to associate this assistant with.
    func assignInteractorAssistant(to assignable: any AssistantAssigning, eventType: any Hashable)
}

public extension InteractorConfiguring {
    var interactorType: InteractorType? { nil }
    var actionType: (any InteractorRequestActionTypeable)? { nil }
    var assistantType: InteractorAssistantType? { nil }
    
    func assignInteractorAssistant(to assignable: any AssistantAssigning, eventType: any Hashable) {}
}
