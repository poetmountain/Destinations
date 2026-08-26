//
//  ActionPerformable.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines an object which can perform an action as part of an ``ActionPerformableCollection`` object. This action generally represents a single Interactor request.
///
/// Conforming types represent discrete, async steps in a sequence or one of several parallel tasks in a group. Each step receives accumulated outputs from prior steps and returns an updated ``ActionCollectionResults`` object, enabling a chain of actions to build on each other's results.
@MainActor public protocol ActionPerformable<ContentType>: AnyObject, Sendable {

    /// The content type which is used to send a request to this action's Interactor.
    associatedtype ContentType: ContentTypeable

    /// A UUID identifier associated with a particular action object.
    var id: UUID { get }
    
    /// An optional conduit used to pass output from this action to a subsequent step in the sequence.
    var outputConduit: (any ActionSequenceConduiting<ContentType>)? { get set }

    /// An optional identifier associated to this action.
    var identifier: (any ActionIdentifying)? { get }

    /// An optional type describing the interactor request action this step performs.
    var actionType: (any InteractorRequestActionTypeable)? { get }

    /// When `true`, a failure in this action will also cancel the parent task group running the sequence.
    var shouldEndParentTaskOnFailure: Bool { get }
    
    /// When `true`, the result of this action is accumulated into the sequence's output collection.
    var shouldSaveResult: Bool { get }
    
    /// Performs the action, optionally using the provided optional content.
    ///
    /// - Parameters:
    ///   - content: Optional content to use when performing the action.
    ///   - sequenceOutputs: The accumulated responses from previous steps in the sequence. This enables responses to be passed forward through the action sequence chain.
    /// - Returns: A `Result` containing the updated ``ActionSequenceResponses`` on success, or an error on failure.
    func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error>

}
