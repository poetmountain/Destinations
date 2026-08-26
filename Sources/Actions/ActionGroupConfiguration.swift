//
//  ActionGroupConfiguration.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Configures a group of Interactor actions which an ``ActionGroup`` runs in parallel as a single step in an ``ActionSequence``.
///
/// Each child configuration makes its own Interactor request; when all have completed, the supplied ``SequenceGroupMerging`` object merges their results into a single content value which is passed on through the group's output conduit. Children can cancel the group's task on a per-child basis with ``GroupStepConfiguration``'s `shouldEndParentTaskOnFailure` property.
public struct ActionGroupConfiguration<InteractorType: InteractorTypeable, ContentType: ContentTypeable>: InteractorConfiguring, ActionCollectionConfiguring {
        
    /// A group has no single action type of its own; this placeholder satisfies the ``ActionConfiguring`` requirement. Each child carries its own real action type.
    public enum GroupActionType: InteractorRequestActionTypeable {
        case group
    }
    public typealias ActionType = GroupActionType

    public let interactorType: InteractorType? = nil

    public let actionType: GroupActionType = .group

    /// Unused. A group has no single assistant. Each child builds its own.
    public let assistant: InteractorAssistantType = .basicAsync
    
    public let configurationType: ActionConfigurationType = .group

    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?

    /// An optional identifier of this group step, carried onto the group's ``ActionResult``.
    public let identifier: (any ActionIdentifying)?

    public let shouldEndParentTaskOnFailure: Bool
    
    public let shouldSaveResult: Bool
    
    /// Determines whether the results of this group's children are saved in its origin when the group's result is passed on
    public let shouldSaveChildResults: Bool
    
    /// An array of action configurations which the group should run in parallel.
    public let actions: [any ActionConfiguring<InteractorType, ContentType>]

    /// Handles request output merging for this group action.
    public let merger: (any ActionResultsMerging<ContentType>)?

    /// Creates a group configuration.
    /// - Parameters:
    ///   - actions: The configurations of the actions which should run in parallel within this group.
    ///   - merger: An object which merges the child action results into a single content value.
    ///   - outputConduit: An optional conduit which passes the merged content on to the next step in the sequence.
    ///   - type: An optional type tagging this group step, used to locate the group's result in an ``ActionSequenceResults`` object.
    public init(actions: [any ActionConfiguring<InteractorType, ContentType>], merger: any ActionResultsMerging<ContentType>, outputConduit: (any ActionSequenceConduiting<ContentType>)? = nil, identifier: (any ActionIdentifying)?, shouldEndParentTaskOnFailure: Bool? = nil, shouldSaveResult: Bool? = nil, shouldSaveChildResults: Bool? = nil) {
        self.actions = actions
        self.merger = merger
        self.outputConduit = outputConduit
        self.identifier = identifier
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure ?? false
        self.shouldSaveResult = shouldSaveResult ?? true
        self.shouldSaveChildResults = shouldSaveChildResults ?? true
    }

    public func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {
        // A group aggregates multiple child assistants and has no single assistant of its own, so it can't be nested as a child of another group.
        let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
        let message = String(format: template, "\(actionType)")
        throw DestinationsError.unsupportedInteractorAssistantType(message: message)
    }

    public func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        
        guard let merger else {
            throw ActionError<ContentType>.missingMerger
        }
        
        let childPerformables = try actions.map { try $0.buildAction(resultHandler: resultHandler) }
        return ActionGroup<ContentType>(actions: childPerformables, merger: merger, identifier: identifier, outputConduit: outputConduit, shouldEndParentTaskOnFailure: shouldEndParentTaskOnFailure, shouldSaveResult: shouldSaveResult, shouldSaveChildResults: shouldSaveChildResults)
    }
}
