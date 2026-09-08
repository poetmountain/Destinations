//
//  Action.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This object represents a single action in an ``ActionPerformableCollection`` object. The actual work done is handled by an Interactor; this object calls ``AsyncInteractorAssisting/asyncRequestForAction(destination:actionType:content:resultTransformer:)`` on its assistant, and upon completion adds its result to a results array it passes along to this step's output conduit. If there is no conduit attached, it will assume the sequence is completed and return all results. If the action's task is cancelled an ``ActionError/cancelled(partialResults:)`` error will be returned; if the interactor returns a failure an ``ActionError/failed(partialResults:)`` error will be returned, both with the accumulated results that completed previously in the sequence.
///
/// > Note: Generally you should not create this object directly. Instead, ``ActionConfiguration`` objects should be used to represent sequence steps in conjunction with an ``ActionSequenceConfiguration`` object.
public final class Action<InteractorType: InteractorTypeable, ContentType: ContentTypeable>: ActionPerformable {

    public let id = UUID()

    public let actionType: (any InteractorRequestActionTypeable)?
    public let identifier: (any ActionIdentifying)?
    private let assistant: any AsyncInteractorAssisting<InteractorType, ContentType>
    private weak var resultHandler: (any InteractorResultHandling<InteractorType, ContentType>)?
    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    public let shouldEndParentTaskOnFailure: Bool
    public let shouldSaveResult: Bool

    /// Converts the Interactor's raw result into `ContentType`, supplied by an ``ActionConfiguration`` when its Interactor's `Request.ResultData` differs from `ContentType`. `nil` when the two types are the same.
    private let resultTransformer: ContentTransformerWrapper<ContentType>?

    public init(actionType: any InteractorRequestActionTypeable, identifier: (any ActionIdentifying)? = nil, assistant: any AsyncInteractorAssisting<InteractorType, ContentType>, resultHandler: any InteractorResultHandling<InteractorType, ContentType>, outputConduit: (any ActionSequenceConduiting<ContentType>)?, shouldEndParentTaskOnFailure: Bool = false, shouldSaveResult: Bool = true, resultTransformer: ContentTransformerWrapper<ContentType>? = nil) {
        self.actionType = actionType
        self.identifier = identifier
        self.assistant = assistant
        self.resultHandler = resultHandler
        self.outputConduit = outputConduit
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure
        self.shouldSaveResult = shouldSaveResult
        self.resultTransformer = resultTransformer
    }
    
    public func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error> {
        
        guard Task.isCancelled == false else {
            return .failure(ActionError<ContentType>.cancelled(partialResults: sequenceOutputs))
        }

        guard let resultHandler else {
            return .failure(ActionError<ContentType>.missingResultHandler)
        }
        
        guard let actionType else {
            return .failure(ActionError<ContentType>.noInteractorActionType)
        }

        let result = await assistant.asyncRequestForAction(destination: resultHandler, actionType: actionType, content: content, resultTransformer: resultTransformer)
     
        switch result {
            case .success(let content):
                var sequenceOutputs = sequenceOutputs
                // If there's no output conduit we should also add the result, because in that case we return the sequence outputs, not the content
                if shouldSaveResult || outputConduit == nil {
                    sequenceOutputs.addResult(result: result, for: actionType, identifier: identifier, shouldSaveResult: shouldSaveResult)
                }
                
                guard Task.isCancelled == false else {
                    return .failure(ActionError<ContentType>.cancelled(partialResults: sequenceOutputs))
                }

                if let outputConduit {
                    return await outputConduit.receive(input: content, sequenceOutputs: sequenceOutputs)

                } else {
                    // There is no output conduit so this must be in the end of the line,
                    // therefore we should just return the current chain action results
                    return .success(sequenceOutputs)
                }
                
            case .failure(let error):
                var sequenceOutputs = sequenceOutputs
                sequenceOutputs.addResult(result: .failure(error), for: actionType, identifier: identifier, shouldSaveResult: shouldSaveResult)
                return .failure(ActionError<ContentType>.failed(partialResults: sequenceOutputs, error: error))
        }

    }

}


