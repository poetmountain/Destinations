//
//  ActionSequence.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This object controls a sequence of actions that are run in serial order, passing output from one sequence step to the next.
///
/// `ActionSequence` manages a chain of ``ActionPerformable`` steps connected by output conduits. Each step receives the content produced by the previous step via its output conduit. The sequence is run starting from the first action, which signals each action to run successively in order. A sequence step can also be an ``ActionGroup``, which runs a collection of actions in parallel.
///
/// > Note: Generally you should not instantiate an ActionSequence directly. Instead you should use an ``ActionSequenceConfiguration`` object to build it. You can either assign this configuration to DestinationProviding/interactorsData and run it via its associated event type, or you can build these configurations within a state model and call Destinationable/performActions(configuration:content:)-c2a7 on its Destination.
///
/// ## Usage
///
/// Build a sequence by composing ``ActionConfiguration`` steps inside an ``ActionSequenceConfiguration`` using the `.step(_:)` / `.conduit(_:)` builder API. Each step except the last must be followed by a conduit that transforms and forwards its output to the next step. 
///
/// ```swift
/// // Step 1: retrieve data from an interactor.
/// let retrievalStep = ActionConfiguration<InteractorType, ContentType, FetchInteractor>(
///     interactorType: .api,
///     action: .retrieve,
///     assistant: .basicAsync,
///     identifier: ActionIdentifier.retrieve)
///
/// // Step 2: process the retrieved data.
/// let processStep = ActionConfiguration<InteractorType, ContentType, ProcessInteractor>(
///     interactorType: .process,
///     action: .transform,
///     assistant: .basicAsync,
///     identifier: ActionIdentifier.process)
///
/// // Link the steps: retrievalStep's output flows through the output conduit into processStep.
/// let filesSequence = try ActionSequenceConfiguration<InteractorType, ContentType>(identifier: ActionIdentifier.fileSequence)
///     .step(retrievalStep)
///     .output(using: FileTransformer())
///     .step(processStep)
///
/// // Run the actions and inspect the accumulated results.
/// let result = await destination.performActions(configuration: filesSequence, content: nil)
///
/// if case .success(let outputs) = result,
///    let processResult = outputs.last(identifier: ActionIdentifier.fileSequence),
///    case .savedFiles(let urls) = processResult.content {
///     // processResult.content holds the final transformed value.
/// }
/// ```
///
@MainActor public final class ActionSequence<ContentType: ContentTypeable>: ActionPerformableCollection {

    public let id = UUID()
    
    /// The ordered list of actions that make up this sequence. The sequence runs each action in order of this array.
    public var actions: [any ActionPerformable<ContentType>] = []

    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    public let identifier: (any ActionIdentifying)?
    public var actionType: (any InteractorRequestActionTypeable)? { nil }
    public let shouldEndParentTaskOnFailure: Bool
    public let shouldSaveResult: Bool
    
    
    /// Creates an `ActionSequence` with an optional initial set of actions.
    ///
    /// - Parameter actions: An optional array of actions to seed the sequence. If `nil`, the sequence starts empty.
    public init(actions: [any ActionPerformable<ContentType>]? = nil, identifier: (any ActionIdentifying)? = nil, outputConduit: (any ActionSequenceConduiting<ContentType>)? = nil, shouldEndParentTaskOnFailure: Bool = false, shouldSaveResult: Bool = true) {
        if let actions {
            self.actions = actions
        }
        self.outputConduit = outputConduit
        self.identifier = identifier
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure
        self.shouldSaveResult = shouldSaveResult
    }
    
    /// Appends a new step to the end of the sequence, linking it to the previous step's output conduit.
    ///
    /// If the sequence already contains at least one action, the last action must have a non-nil `outputConduit`; the new step is assigned as that conduit's `outputAction` before being appended. If the sequence is empty, the step is appended directly.
    ///
    /// - Parameter action: The action to append as the next step in the sequence.
    /// - Throws: ``ActionError/missingConduit`` if the current last action has no output conduit.
    public func add(action: any ActionPerformable<ContentType>) throws {
                
        if let lastAction = actions.last {
            guard lastAction.outputConduit != nil else {
                throw ActionError<ContentType>.missingConduit
            }
            
            lastAction.outputConduit?.outputAction = action
            actions.append(action)

        } else if actions.count == 0 {
            actions.append(action)
        }
        
    }

    /// Starts the action sequence, passing in optional content to be used when running the first action in the sequence.
    ///
    /// Each action is responsible for forwarding results to subsequent steps via its output conduit. The accumulated outputs from all steps are returned upon completion.
    ///
    /// - Parameter content: Optional initial content passed to the first action.
    /// - Returns: A `Result` containing ``ActionSequenceResults`` with all step outputs on success,
    ///   or an error if the sequence is empty or any step fails.
    public func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error> {
        guard let firstAction = actions.first else {
            return .failure(ActionError<ContentType>.noActionsAvailable)
        }
                
        return await firstAction.perform(with: content, sequenceOutputs: sequenceOutputs)
        
    }
    
}
