//
//  InteractorRequestConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an Interactor configuration model which defines a request to perform an action.
public protocol InteractorRequestConfiguring {
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: InteractorRequestActionTypeable
    
    /// The type of data that is returned from a datasource.
    associatedtype ResultData: Hashable
    
    /// The type of action to request being performed.
    var action: ActionType { get set }
}

/// This protocol represents an enum which defines types of actions for a particular Interactor.
public protocol InteractorRequestActionTypeable: Hashable {}
