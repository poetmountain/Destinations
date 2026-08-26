//
//  ActionBranch.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A single branching path in an ``ActionBranch``, pairing a ``BranchConditionable`` condition with an action and an optional output transformer.
///
/// When an ``ActionBranch`` performs, it evaluates each path's condition in order and runs the first matching action. The path's optional transformer converts the action's output before the branch forwards the result through its output conduit to the next sequence step.
///
/// > Note: Do not create these directly. Use ``ActionBranchConfiguration``'s `.branch(when:action:transformer:)` builder method, which constructs ``ActionBranchPath`` objects automatically when building the ``ActionBranch``.
@MainActor public struct ActionBranchPath<ContentType: ContentTypeable> {

    /// The condition that determines whether this branch path is selected.
    public let condition: any BranchConditionable<ContentType>

    /// The action to run when this path is selected.
    public let action: any ActionPerformable<ContentType>

    /// An optional transformer applied to the branch path's result before forwarding to the next sequence step. Use this when the path's output shape differs from what the downstream step expects.
    public let transformer: (any ContentTransformable<ContentType>)?

    public init(condition: any BranchConditionable<ContentType>, action: any ActionPerformable<ContentType>, transformer: (any ContentTransformable<ContentType>)? = nil) {
        self.condition = condition
        self.action = action
        self.transformer = transformer
    }
}
