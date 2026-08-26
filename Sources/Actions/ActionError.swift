//
//  ActionError.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Errors thrown by ``ActionSequence`` during configuration and while an ``Action`` or ``ActionGroup`` is running.
public enum ActionError<ContentType: ContentTypeable>: LocalizedError {
    
    /// The action collection contains no actions and cannot be performed.
    case noActionsAvailable
    
    /// A sequence step is missing the output conduit required to pass its result to the next step.
    case missingConduit
    
    /// A required action could not be found when building or running a sequence step.
    case missingAction
    
    /// A group step is missing the merger required to pass its result to the next step.
    case missingMerger
    
    /// A sequence step has no result handler configured to receive the interactor's response.
    case missingResultHandler
    
    /// An action configuration has an invalid configuration.
    case invalidConfiguration

    /// An interactor action type was defined on an ``ActionPerformable`` object.
    case noInteractorActionType
    
    /// The configuration is not a configuration object that can create an ``ActionPerformable`` object.
    case notActionConfiguration
    
    /// The action collection's task was cancelled before all steps completed. Contains results from the actions which completed before cancellation occurred.
    case cancelled(partialResults: ActionCollectionResults<ContentType>)

    /// An action, transformer, or group merger failed, stopping further progress. Contains results from the actions which completed before the failure occurred, and the error that caused the failure.
    case failed(partialResults: ActionCollectionResults<ContentType>, error: any Error)

    public var errorDescription: String? {
        switch self {
            case .noActionsAvailable:
                "The action collection contains no actions and cannot be performed."
            case .missingConduit:
                "A sequence step is missing the output conduit required to pass its result to the next step."
            case .missingAction:
                "A required action could not be found when building or running a sequence step."
            case .missingMerger:
                "A group step is missing the merger required to pass its result to the next step."
            case .missingResultHandler:
                "A sequence step has no result handler configured to receive the interactor's response."
            case .invalidConfiguration:
                "An action configuration has an invalid configuration."
            case .noInteractorActionType:
                "An interactor action type was defined on an ActionPerformable object."
            case .notActionConfiguration:
                "The configuration is not a configuration object that can create an ActionPerformable object."
            case .cancelled(_):
                "The action collection's task was cancelled before all steps completed. Contains results from the actions which completed before cancellation occurred."
            case .failed(_, let underlyingError):
                "An action, transformer, or group merger failed: \(underlyingError.localizedDescription). Contains results from the actions which completed before the failure occurred."
        }
    }
}
