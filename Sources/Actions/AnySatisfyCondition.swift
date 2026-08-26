//
//  AnySatisfyCondition.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A branch condition that passes when at least one of its child ``conditions`` passes (logical OR).
///
/// Use `.negated()` on an `AnySatisfyCondition` to select a path when none of the child conditions match.
public struct AnySatisfyCondition<ContentType: ContentTypeable>: BranchConditionable {

    /// The child conditions, at least one of which must pass for this condition to pass.
    public let conditions: [any BranchConditionable<ContentType>]

    /// - Parameter conditions: The individual branch conditions to be tested.
    public init(conditions: [any BranchConditionable<ContentType>]) {
        self.conditions = conditions
    }

    public func evaluate(content: ContentType?) -> Bool {
        conditions.contains { $0.evaluate(content: content) }
    }
}
