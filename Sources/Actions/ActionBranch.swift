//
//  ActionBranch.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An ``ActionPerformable`` conforming type which selects and runs one of several actions based on provided conditions, evaluated against the current content and previous results in a sequence and runs the first path whose conditions return `true`. Branches are mainly only used as a step in an ``ActionSequence``.
///
/// `ActionBranch` evaluates its ``BranchConditionable`` conditions in declaration order and runs the first path whose condition (or conditions, if a group condition like ``AllSatisfyCondition`` or ``AnySatisfyCondition`` is used) returns `true`. If no condition matches and there's no fallback action, the branch fails with ``ActionError/cancelled(partialResults:)``. To guarantee a fallback path, you can add on an `.otherwise` path at the end of the branch chain. After the selected path action completes, `ActionBranch` applies the path's optional transformer to the result and forwards the content through its own output conduit to the next sequence step, recording one ``ActionResult`` with origin ``ActionResponseOrigin/branch``.
///
/// In the example below, if there are images passed-in from the previous step, it will process the images with a filter. If instead the content is text, it will render the text into an image. If neither was provided, it will choose the fallback action. This branch object could then be used as a sequence step or in a group of actions.
///
/// ```swift
/// let branch = ActionBranchConfiguration<AppInteractorType, AppContentType>()
///     .branch(when: HasImagesCondition(), action: processImageStep)
///     .branch(when: HasTextCondition(),   action: renderTextStep)
///     .otherwise(fallbackAction)
/// ```
///
/// > Note: Do not instantiate this type directly. Use ``ActionBranchConfiguration`` to define and build a branch step.
@MainActor public final class ActionBranch<ContentType: ContentTypeable>: ActionPerformable {

    public let id = UUID()

    /// Always `nil`; a branch does not represent a single interactor action type.
    public var actionType: (any InteractorRequestActionTypeable)? { nil }

    public let identifier: (any ActionIdentifying)?

    /// The conduit that receives the selected branch path's (optionally transformed) output and forwards it to the next sequence step.
    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?

    public let shouldEndParentTaskOnFailure: Bool
    public let shouldSaveResult: Bool

    /// The ordered list of branch paths. Conditions are evaluated in declaration order; the first match is selected.
    public var cases: [ActionBranchPath<ContentType>]

    public init(cases: [ActionBranchPath<ContentType>], identifier: (any ActionIdentifying)? = nil, outputConduit: (any ActionSequenceConduiting<ContentType>)? = nil, shouldEndParentTaskOnFailure: Bool = false, shouldSaveResult: Bool = true) {
        self.cases = cases
        self.identifier = identifier
        self.outputConduit = outputConduit
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure
        self.shouldSaveResult = shouldSaveResult
    }

    /// Evaluates each branch path condition in order, runs the first matching path, and forwards its (optionally transformed) output to the next sequence step.
    ///
    /// - Parameters:
    ///   - content: The content value forwarded from the previous sequence step.
    ///   - sequenceOutputs: The accumulated results from all prior steps in the sequence.
    /// - Returns: `.success` with the updated ``ActionCollectionResults`` on success, or `.failure` wrapping an ``ActionError`` if no condition matched, the selected branch path failed, or the task was cancelled.
    public func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error> {

        guard Task.isCancelled == false else {
            return .failure(ActionError<ContentType>.cancelled(partialResults: sequenceOutputs))
        }

        guard let matched = cases.first(where: { $0.condition.evaluate(content: content) }) else {
            if content != nil {
                return .success(sequenceOutputs)
            } else {
                return .failure(ActionError<ContentType>.cancelled(partialResults: sequenceOutputs))
            }
        }

        let actionResult = await matched.action.perform(with: content, sequenceOutputs: sequenceOutputs)

        switch actionResult {
            case .success(let pathOutputs):
                guard Task.isCancelled == false else {
                    // Use pathOutputs, not the stale pre-call sequenceOutputs, so the matched path's
                    // already-completed result isn't silently dropped from the partial results.
                    return .failure(ActionError<ContentType>.cancelled(partialResults: pathOutputs))
                }

                // Extract only the results contributed by the selected path
                let pathResults = Array(pathOutputs.results.dropFirst(sequenceOutputs.results.count))

                guard let lastResult = pathResults.last else {
                    // The selected path produced no new result (e.g. `.skip`). Per its contract, this
                    // contributes no result to the outputs, but we still forward the original content
                    // through unchanged so the sequence doesn't dead-end if there's a next step.
                    if let outputConduit, let content {
                        return await outputConduit.receive(input: content, sequenceOutputs: pathOutputs)
                    } else {
                        return .success(pathOutputs)
                    }
                }
                let lastContent = lastResult.content
                
                // Apply the branch path's transformer, if one was configured
                let forwardContent: ContentType?
                if let transformer = matched.transformer, let lastContent {
                    do {
                        forwardContent = try transformer.transform(input: lastContent)
                    } catch {
                        return .failure(error)
                    }
                } else {
                    forwardContent = lastContent
                }

                // Record one branch-level result on top of the prior sequenceOutputs
                var outputs = sequenceOutputs
                if let forwardContent, shouldSaveResult || outputConduit == nil {
                    outputs.add(ActionResult(identifier: lastResult.identifier, origin: .branch, result: .success(forwardContent)))
                }

                if let outputConduit, let forwardContent {
                    return await outputConduit.receive(input: forwardContent, sequenceOutputs: outputs)
                } else {
                    return .success(outputs)
                }

            case .failure(let error):
                return .failure(error)
        }
    }
}
