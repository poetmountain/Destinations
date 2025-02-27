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
public protocol InteractorRequestConfiguring: Sendable {
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: InteractorRequestActionTypeable
    
    /// The type of content that is send with a request to an interactor.
    associatedtype RequestContentType: ContentTypeable
    
    /// An enum type representing the type of data that is returned from an interactor.
    associatedtype ResultData: ContentTypeable
    
    /// A content model type which this interactor returns.
    associatedtype Item: Hashable
    
    /// The type of action to request being performed.
    var action: ActionType { get }
    
    init(action: ActionType)
}

/// This protocol represents an enum which defines types of actions for a particular Interactor.
public protocol InteractorRequestActionTypeable: Hashable, Sendable {}
