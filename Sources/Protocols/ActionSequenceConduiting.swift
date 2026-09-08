//
//  ActionSequenceConduiting.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines a conduit between steps in an action sequence.
///
/// Conduit objects that conform to this protocol receive the output of the current sequence step action and optionally transform the output into a data form the next action can use the next action in the sequence, before then injecting the output into the next step in the sequence.
@MainActor public protocol ActionSequenceConduiting<ContentType> {
    associatedtype ContentType: ContentTypeable
    
    /// The next action to be performed after this conduit processes its input.
    var outputAction: (any ActionPerformable<ContentType>)? { get set }

    /// An optional transformer that converts the output of the current action sequence step before forwarding it to ``outputAction``.
    var transformer: (any ContentTransformable<ContentType, ContentType>)? { get set }

    /// Receives the current sequence step's output and forwards it to the next action in the sequence.
    ///
    /// - Parameters:
    ///   - input: The output of the current sequence step's action which should be passed to the next action in the sequence.
    ///   - sequenceOutputs: The accumulated responses from all previously completed steps in the sequence.
    /// - Returns: A `Result` containing the updated ``ActionSequenceResponses`` on success, or an `Error` on failure.
    func receive(input: ContentType, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, Error>
    
}
