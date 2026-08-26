//
//  ActionResult.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This object defines the result of an Action.
public struct ActionResult<ContentType: ContentTypeable>: Sendable {

    /// An optional type identifying the step which produced this output, assigned when the step was configured. Used to locate a specific output in the sequence's responses.
    public let identifier: (any ActionIdentifying)?

    /// What produced this response — a single Interactor action or a group of actions.
    public let origin: ActionResponseOrigin<ContentType>

    /// A convenience property for accessing the content of the result, if the action was successful. For a group, this is the value produced by the group's ``SequenceGroupMerging`` object.
    public let content: ContentType?
        
    /// A Result object holding either the content of the result, or an error if the action failed. For a group, a successful result passes the value produced by the group's ``SequenceGroupMerging`` object.
    public let result: Result<ContentType, Error>

    public init(identifier: (any ActionIdentifying)? = nil, origin: ActionResponseOrigin<ContentType>, result: Result<ContentType, Error>) {
        self.identifier = identifier
        self.origin = origin
        self.result = result
        
        if case .success(let content) = result {
            self.content = content
        } else {
            self.content = nil
        }
    }

    /// A convenience accessor for the Interactor action type of an `.action` result. Returns `nil` for a `.group` result.
    public var action: (any InteractorRequestActionTypeable)? {
        if case .action(let actionType) = origin {
            return actionType
        }
        return nil
    }
}
