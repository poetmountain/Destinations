//
//  ActionBranchPathConfiguration.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A configuration object that pairs a ``ActionBranchCondition`` with an action configuration and an optional transformer, representing one path of an ``ActionBranchConfiguration``.
///
/// Use ``ActionBranchConfiguration``'s `.branch(when:action:transformer:)` builder method to add these to a branch configuration rather than constructing them directly.
@MainActor public struct ActionBranchPathConfiguration<InteractorType: InteractorTypeable, ContentType: ContentTypeable> {

    /// The condition evaluated at runtime to determine whether this branch path should be selected.
    public let condition: any BranchConditionable<ContentType>

    /// The configuration for the action to build and run when this branc path is selected.
    public let actionConfig: any ActionConfiguring<InteractorType, ContentType>

    /// An optional transformer applied to the branch path's output before forwarding it downstream.
    public let transformer: (any ContentTransformable<ContentType>)?

    public init(condition: any BranchConditionable<ContentType>, actionConfig: any ActionConfiguring<InteractorType, ContentType>, transformer: (any ContentTransformable<ContentType>)? = nil) {
        self.condition = condition
        self.actionConfig = actionConfig
        self.transformer = transformer
    }
}
