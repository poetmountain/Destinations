//
//  ActionGroup.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A group of actions which run concurrently, merging their results into one content value.
///
/// The child requests all run concurrently and receive the same input content. When they complete, a ``ActionResultsMerging`` object merges their results into a single content value. The group passes this content value and all of the group's child results via a single ``ActionResult``, and passes the merged value on through its output conduit.
///
/// ## Child failure behavior
///
/// Each child's `shouldEndParentTaskOnFailure` flag controls what happens when that child fails:
///
/// - **`true`**: The group immediately calls `cancelAll()` on its remaining siblings, builds a group-level ``ActionResult`` containing all results collected up to that point plus the failing child's failure result, and returns ``ActionError/cancelled(partialResults:)``. Siblings that had not yet completed are cancelled.
///
/// - **`false`**: The group records the failure and lets all remaining siblings run to completion. Once every child has finished, the group builds a single group-level ``ActionResult`` whose `origin` property includes child results for every task's success or failure in declaration order, then returns ``ActionError/cancelled(partialResults:)``. The merger is not called because not all children succeeded.
///
/// In both cases the caller receives one group ``ActionResult`` with a ``ActionResponseOrigin/group(results:)`` origin. Use ``ActionCollectionResults/failedActions()`` on the partial results to inspect which children failed.
///
/// > Note: You should not instantiate an `ActionGroup` directly. Instead you should create an ``ActionGroupConfiguration`` object to define it, and used in conjunction with ``Destinationable/performActions(configuration:content:)-1nsw5``.
///
/// ## Usage
///
/// Build a group by composing child ``ActionConfiguration`` objects inside an ``ActionGroupConfiguration``. You can either assign this configuration to ``DestinationProviding/interactorsData`` and run it via its associated event type, or you can build these configurations within a state model and call ``Destinationable/performActions(configuration:content:)-c2a7`` on its Destination.
///
/// ```swift
/// // Each child configuration represents one parallel Interactor request.
/// let retrievalChildren: [any ActionConfiguring<InteractorType, ContentType>] = [
///     ActionConfiguration<InteractorType, ContentType, MyInteractor>(
///         interactorType: .myType,
///         action: .retrieveFile,
///         assistant: .basicAsync,
///         identifier: ActionIdentifier.retrieve),
///     ActionConfiguration<InteractorType, ContentType, MyInteractor>(
///         interactorType: .myType,
///         action: .retrieveFile,
///         assistant: .basicAsync,
///         identifier: ActionIdentifier.retrieve)
/// ]
///
/// // The merger combines each child's result into a single ContentType value.
/// let retrievals = ActionGroupConfiguration<InteractorType, ContentType>(
///     actions: retrievalChildren,
///     merger: FileMerger(),
///     identifier: ActionIdentifier.retrievalGroup)
///
/// let result = await destination.performActions(configuration: retrievals, content: nil)
///
/// if case .success(let outputs) = result,
///    let groupResult = outputs.last(identifier: ActionIdentifier.retrievalGroup) {
///     // groupResult.content holds the merged value from all parallel children.
/// }
/// ```
public final class ActionGroup<ContentType: ContentTypeable>: ActionPerformableCollection {

    /// A unique identifier for this group instance.
    public let id = UUID()

    /// The child actions that run concurrently when this group is performed.
    public var actions: [any ActionPerformable<ContentType>] = []

    /// The object responsible for merging each child's result into a single content value.
    private let merger: any ActionResultsMerging<ContentType>

    /// An optional identifier used to tag this group's ``ActionResult`` in the sequence outputs.
    public let identifier: (any ActionIdentifying)?

    /// An optional conduit that receives the merged content value and passes it to the next step in the sequence.
    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?

    /// Always `nil`; a group does not represent a single interactor action type.
    public var actionType: (any InteractorRequestActionTypeable)? { nil }

    /// Controls how a failure in this group propagates to its parent sequence. When `true`, siblings are cancelled immediately and the group fails fast. When `false`, all siblings run to completion and every result is collected before the group returns with a `.failure` Result. See the type-level documentation for the full behavioral description.
    public let shouldEndParentTaskOnFailure: Bool

    /// When `true`, the merged result is recorded in the sequence outputs. Defaults to `true`.
    public let shouldSaveResult: Bool
    
    /// Determines whether the results of this group's children are saved in its origin when the group's result is passed on
    public let shouldSaveChildResults: Bool

    /// Creates a new action group.
    ///
    /// - Parameters:
    ///   - actions: The child actions to run concurrently. Pass `nil` to start with an empty group and add actions later via ``add(action:)``.
    ///   - merger: The object that merges each child's ``ActionResult`` into a single `ContentType` value.
    ///   - identifier: An optional identifier attached to the group's recorded ``ActionResult``.
    ///   - outputConduit: An optional conduit that forwards the merged content value to the next sequence step.
    ///   - shouldEndParentTaskOnFailure: Pass `true` to cancel sibling actions and fail the sequence when any child fails. Defaults to `false`.
    ///   - shouldSaveResult: Pass `false` to skip recording the merged result in the sequence outputs. Defaults to `true`.
    public init(actions: [any ActionPerformable<ContentType>]? = nil, merger: any ActionResultsMerging<ContentType>, identifier: (any ActionIdentifying)? = nil, outputConduit: (any ActionSequenceConduiting<ContentType>)? = nil, shouldEndParentTaskOnFailure: Bool? = nil, shouldSaveResult: Bool? = nil, shouldSaveChildResults: Bool? = nil) {
        if let actions {
            self.actions = actions
        }
        self.merger = merger
        self.identifier = identifier
        self.outputConduit = outputConduit
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure ?? false
        self.shouldSaveResult = shouldSaveResult ?? true
        self.shouldSaveChildResults = shouldSaveChildResults ?? true
    }
    
    /// Appends an action to the group's child action list.
    ///
    /// - Parameter action: The action to add.
    /// - Throws: ``ActionError`` if the action cannot be added.
    public func add(action: any ActionPerformable<ContentType>) throws {
        actions.append(action)
    }

    /// Runs all child actions concurrently, merges their results, and returns the updated sequence outputs.
    ///
    /// Each child action receives the same `content` value and the current `sequenceOutputs`. When all children
    /// complete successfully, their individual ``ActionResult`` values are merged into a single `ContentType` by
    /// the group's ``ActionResultsMerging`` object. The group then appends one ``ActionResult`` (with origin
    /// ``ActionResponseSource/group(results:)``) to the outputs and, if an ``outputConduit`` is set, forwards
    /// the merged value to the next sequence step.
    ///
    /// - Parameters:
    ///   - content: The input content passed to every child action.
    ///   - sequenceOutputs: The accumulated results from all prior steps in the sequence.
    /// - Returns: `.success` with the updated ``ActionCollectionResults`` on success, or `.failure` wrapping an
    ///   ``ActionError`` if a child fails, the merger throws, or the task is cancelled.
    public func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error> {

        guard Task.isCancelled == false else {
            return .failure(ActionError<ContentType>.cancelled(partialResults: sequenceOutputs))
        }

        // Child tasks run in parallel. Each receives a copy of the current sequenceOutputs, performs its action, and returns the updated outputs. The group extracts the last result from each child's return value.
        let childrenResult = await withTaskGroup(of: (index: Int, result: Result<ActionCollectionResults<ContentType>, any Error>).self, returning: Result<[ActionCollectionResults<ContentType>], any Error>.self) { group in

            for (index, action) in actions.enumerated() {
                group.addTask {
                    let result = await action.perform(with: content, sequenceOutputs: sequenceOutputs)
                    return (index, result)
                }
            }

            var results = [ActionCollectionResults<ContentType>?](repeating: nil, count: actions.count)
            var childFailures: [Int: Error] = [:]
            var firstFailure: Error? = nil
            
            // iterate through the group results and collect each child task's outputs
            for await (index, result) in group {
                switch result {
                    case .success(let childOutputs):
                        if actions[index].shouldSaveResult {
                            results[index] = childOutputs
                        }
                        
                    case .failure(let error):
                        // if failures should end the TaskGroup, we should cancel it and collect both the success and failure results for each child output and return them in the `.cancelled()` ActionError
                        if actions[index].shouldEndParentTaskOnFailure {
                            group.cancelAll()
                            var partialOutputs = sequenceOutputs
                            var childResults: [ActionResult<ContentType>] = results.compactMap { $0?.results.last }
                            let failingOrigin: ActionResponseOrigin<ContentType> = actions[index].actionType.map { .action($0) } ?? .none
                            childResults.append(ActionResult(identifier: actions[index].identifier, origin: failingOrigin, result: .failure(error)))
                            partialOutputs.add(ActionResult(identifier: identifier, origin: .group(results: childResults), result: .failure(error)))
                            return .failure(ActionError<ContentType>.cancelled(partialResults: partialOutputs))
                        }
                        
                        // if we shouldn't end the TaskGroup on failure then just add the error to the failures array and continue
                        childFailures[index] = error
                        if firstFailure == nil { firstFailure = error }
                }
            }
            
            if let firstFailure {
                var partialOutputs = sequenceOutputs
                var childResults: [ActionResult<ContentType>] = []
                for i in 0..<actions.count {
                    if let lastResult = results[i]?.results.last {
                        childResults.append(lastResult)
                    } else if let error = childFailures[i] {
                        let failingOrigin: ActionResponseOrigin<ContentType> = actions[i].actionType.map { .action($0) } ?? .none
                        childResults.append(ActionResult(identifier: actions[i].identifier, origin: failingOrigin, result: .failure(error)))
                    }
                }
                partialOutputs.add(ActionResult(identifier: identifier, origin: .group(results: childResults), result: .failure(firstFailure)))
                return .failure(ActionError<ContentType>.cancelled(partialResults: partialOutputs))
            }
            return .success(results.compactMap { $0 })
        }

        switch childrenResult {
            case .success(let childOutputsList):
                // Extract the last ActionResult from each child's outputs — each child contributes exactly one result.
                let childResults = childOutputsList.compactMap { $0.results.last }

                guard Task.isCancelled == false else {
                    // Use childResults, not the stale pre-call sequenceOutputs, so the children's
                    // already-completed results aren't silently dropped from the partial results.
                    var partialOutputs = sequenceOutputs
                    partialOutputs.add(ActionResult(identifier: identifier, origin: .group(results: childResults), result: .failure(CancellationError())))
                    return .failure(ActionError<ContentType>.cancelled(partialResults: partialOutputs))
                }

                // A group always merges its child results into a single content value. This is both the group's recorded result and, if an output conduit exists, the value passed on to the next step.
                let mergedContent: ContentType
                do {
                    mergedContent = try merger.merge(results: childResults)
                } catch {
                    var partialOutputs = sequenceOutputs
                    partialOutputs.add(ActionResult(identifier: identifier, origin: .group(results: childResults), result: .failure(error)))
                    return .failure(ActionError<ContentType>.failed(partialResults: partialOutputs, error: error))
                }

                var outputs = sequenceOutputs
                if shouldSaveResult || outputConduit == nil {
                    let resultsToSave = (shouldSaveChildResults == true) ? childResults : []
                    outputs.add(ActionResult(identifier: identifier, origin: .group(results: resultsToSave), result: .success(mergedContent)))
                }
                
                if let outputConduit {
                    return await outputConduit.receive(input: mergedContent, sequenceOutputs: outputs)
                } else {
                    // There is no output conduit so this must be the end of the line,
                    // therefore we should just return the current chain of action results.
                    return .success(outputs)
                }

            case .failure(let error):
                return .failure(error)
        }

    }

}
