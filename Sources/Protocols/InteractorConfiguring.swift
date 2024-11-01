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
public protocol InteractorConfiguring<InteractorType> {
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: InteractorRequestActionTypeable
    
    /// The type of interactor.
    var interactorType: InteractorType { get set }
    
    /// The type of interactor request action.
    var actionType: ActionType { get set }
}
