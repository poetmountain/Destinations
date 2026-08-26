//
//  ActionResultsMerging.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents objects that merge the results of an ``ActionGroup``'s child actions into a single content value which is passed on through the group's output conduit. This merging step is necessary in order for an ``ActionGroup`` to participate in the action sequence, as the sequence expects a single ContentType value to be passed from action to action.
@MainActor public protocol ActionResultsMerging<ContentType> {

    /// The type of content to be returned by the merge action.
    associatedtype ContentType: ContentTypeable

    /// Merges the results of a group's actions into one content value.
    /// - Parameter results: The child action results, in the order their configurations were declared in the group.
    /// - Returns: A single content value representing the merged result of the group's actions.
    func merge(results: [ActionResult<ContentType>]) throws -> ContentType
}
