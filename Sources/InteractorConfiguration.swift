//
//  InteractorConfiguration.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This model is used to configure how an interactor is used in a Destination.
public struct InteractorConfiguration<InteractorType: InteractorTypeable, Interactor: Interactable>: InteractorConfiguring {
    public typealias ActionType = Interactor.Request.ActionType
    
    public var interactorType: InteractorType
    public var actionType: ActionType
    
    /// The initializer.
    /// - Parameters:
    ///   - interactorType: The type of interactor.
    ///   - actionType: The type of interactor request action.
    public init(interactorType: InteractorType, actionType: ActionType) {
        self.interactorType = interactorType
        self.actionType = actionType

    }
}
