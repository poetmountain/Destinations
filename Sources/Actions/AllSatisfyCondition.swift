//
//  AllSatisfyCondition.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A branch condition that passes only when all of its child ``conditions`` pass (logical AND).
public struct AllSatisfyCondition<ContentType: ContentTypeable>: BranchConditionable {

    /// The child conditions that must all pass for this condition to pass.
    public let conditions: [any BranchConditionable<ContentType>]

    /// - Parameter conditions: The individual branch conditions to be tested.
    public init(conditions: [any BranchConditionable<ContentType>]) {
        self.conditions = conditions
    }

    public func evaluate(content: ContentType?) -> Bool {
        conditions.allSatisfy { $0.evaluate(content: content) }
    }
}
