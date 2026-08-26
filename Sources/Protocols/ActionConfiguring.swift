//
//  ActionConfiguring.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an object that can be used to configure an ``Action`` for use in an ``ActionPerformableCollection`` object.
@MainActor public protocol ActionConfiguring<InteractorType, ContentType> {
    associatedtype InteractorType: InteractorTypeable
    associatedtype ActionType: InteractorRequestActionTypeable
    associatedtype ContentType: ContentTypeable

    /// The interactor type associated with this configuration, if any. 
    var interactorType: InteractorType? { get }
    
    /// The type of Interactor action type.
    var actionType: ActionType { get }
    
    /// The type of Interactor assistant.
    var assistant: InteractorAssistantType { get }
    
    /// The output conduit to be used to pass this action's output to the next action.
    var outputConduit: (any ActionSequenceConduiting<ContentType>)? { get set }

    /// An optional type tagging this step, carried onto its ``ActionResponse`` so the response can be located in an ``ActionSequenceResponses`` object. Defaults to `nil`.
    var identifier: (any ActionIdentifying)? { get }

    /// Determines whether on failure the action should cancel its parent task.
    var shouldEndParentTaskOnFailure: Bool { get }
    
    /// Determines whether the result of this action should be saved and returned in the collection's ``ActionCollectionResults`` object. This won't prevent the result from being passed through its `outputConduit` to the next action. Setting this property to `false` can be helpful in cases where you don't want to retain content that takes up a large amount of memory, such as an image retrieved from a server.
    var shouldSaveResult: Bool { get }
    
    /// Builds the interactor assistant this configuration's step will use to make its request. Building the assistant here allows access to the concrete Interactor type, which is erased at the sequence level.
    ///
    /// This is used both to build a standalone ``Action`` and to build the child assistants of an ``ActionGroup``.
    /// - Returns: An async interactor assistant for this configuration's action.
    func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType>

    /// Builds a runnable sequence step from this configuration, also constructing the Interactor assistant the step will use to make its request. Building the assistant here allows access to the concrete Interactor type, which is erased at the sequence level.
    /// - Parameter resultHandler: The object which should handle the results of the step's interactor request.
    /// - Returns: A `Result` containing the step, or a failure if the configured assistant is incompatible with this configuration's types.
    func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType>

}

public extension ActionConfiguring {
    var identifier: (any ActionIdentifying)? { nil }
    var interactorType: InteractorType? { nil }
}
