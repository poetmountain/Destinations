//
//  BooleanCondition.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A branch condition that tests a single Boolean value.
///
/// Pass a Boolean value to test its value at construction time. A `true` value passes the condition. Chaining `.negated()` to it turns the value expectation to `false` for the condition to pass.
public struct BooleanCondition<ContentType: ContentTypeable>: BranchConditionable {

    /// The boolean value to test.
    public let value: Bool

    /// - Parameter value: The boolean value to test. The condition passes when this is `true`.
    public init(_ value: Bool) {
        self.value = value
    }

    public func evaluate(content: ContentType?) -> Bool {
        value
    }
}
