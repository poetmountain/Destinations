//
//  BranchConditionable.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines a condition used to select a branch path in an ``ActionBranch`` step.
///
/// When an ``ActionBranch`` runs, it evaluates each ``BranchConditionable`` condition in order by calling their ``evaluate(content:)`` method and selects the first case whose condition returns `true`. This protocol also provides an implementation of ``negated()`` so that a the same condition can be used in the inverse sense (i.e. "is online" vs. "is offline").
///
/// Implement this protocol to define reusable, named conditions:
/// ```swift
/// struct HasImagesCondition: BranchConditionable {
///     func evaluate(content: AppContent?) -> Bool {
///         guard case .images(let images) = content else { return false }
///         return !images.isEmpty
///     }
/// }
/// ```
@MainActor public protocol BranchConditionable<ContentType> {

    /// The content type this condition evaluates.
    associatedtype ContentType: ContentTypeable

    /// Evaluates the condition against the current content. There are a few simple conditions provided with Destinations such as ``BooleanCondition``, ``AllSatisfyCondition``, and ``AnySatisfyCondition``, but you can implement this protocol to provide your own custom condition logic here.
    ///
    /// - Parameter content: The content value forwarded to this branch step by the preceding conduit.
    /// - Returns: `true` if this condition's branch path should be selected; `false` otherwise.
    func evaluate(content: ContentType?) -> Bool
    
    /// A chainable method that provides a logical inverse of this condition that returns the opposite evaluation. For instance, if you have an `IsOnlineCondition` and chain this method, it would functionally act as an `IsOfflineCondition`.
    ///
    /// Use `.negated()` to reuse an existing condition type in its opposite sense, avoiding a separate type with duplicated evaluation logic.
    ///
    /// ```swift
    /// .branch(when: IsUserLoggedInCondition().negated(), action: showLoginUI)
    /// ```
    ///
    /// - Returns: A ``NegatedCondition`` that passes whenever this condition would not, and vice versa.
    func negated() -> NegatedCondition<ContentType>
}

// MARK: - NegatedCondition

/// A condition that produces the logical inverse of a wrapped ``BranchConditionable``.
///
/// Obtain one via `.negated()` on any condition rather than constructing this type directly.
public struct NegatedCondition<ContentType: ContentTypeable>: BranchConditionable {
    private let base: any BranchConditionable<ContentType>

    init(_ base: any BranchConditionable<ContentType>) {
        self.base = base
    }

    public func evaluate(content: ContentType?) -> Bool {
        !base.evaluate(content: content)
    }
}

public extension BranchConditionable {

    func negated() -> NegatedCondition<ContentType> {
        NegatedCondition(self)
    }
}
