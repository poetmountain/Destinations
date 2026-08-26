//
//  ActionResponseOrigin.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This object represents the origin type of an ``ActionResult`` produced by a sequence step in an ``ActionSequence``.
public enum ActionResponseOrigin<ContentType: ContentTypeable>: Sendable {

    /// The response came from a single Interactor request, carrying the action type of that request.
    case action(any InteractorRequestActionTypeable)

    /// The response came from an ``ActionGroup``. The associated value holds the results of the group's child actions, in the order they were declared.
    case group(results: [ActionResult<ContentType>]?)

    /// The response came from an ``ActionBranch`` step.
    case branch
    
    case none
}
