//
//  ActionBranchConfiguration.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A configuration object that defines an ``ActionBranch`` step for use within an ``ActionSequenceConfiguration``.
///
/// Build a branch by chaining `.branch(when:action:transformer:)` calls, then optionally adding `.otherwise(action:transformer:)` as a fallback that runs when no condition matches. This object evaluates branch path conditions in declaration order at runtime and runs the first matching path. Each path can carry an optional transformer that converts its output before the branch forwards it through the shared output conduit (assigned by ``ActionSequenceConfiguration``'s `.output()` method).
///
/// ```swift
/// let config = try ActionSequenceConfiguration<InteractorType, ContentType>()
///     .step(
///         ActionBranchConfiguration<InteractorType, ContentType>()
///             .branch(when: HasImagesCondition(), action: processImageStep, transformer: ImageToFileTransformer())
///             .branch(when: HasTextCondition(), action: processTextStep)
///             .otherwise(defaultStep)
///     )
///     .output()
///     .step(nextStep)
/// ```
///
/// - Note: `ActionBranchConfiguration` is value-typed; each chained call returns a modified copy.
@MainActor public struct ActionBranchConfiguration<InteractorType: InteractorTypeable, ContentType: ContentTypeable>: ActionConfiguring {

    /// A placeholder action type satisfying the ``ActionConfiguring`` requirement. A branch has no single interactor action of its own.
    public enum ActionBranchType: InteractorRequestActionTypeable {
        case actionBranch
    }
    public typealias ActionType = ActionBranchType

    public let actionType: ActionBranchType = .actionBranch

    /// Unused; a branch aggregates multiple child actions and has no single assistant of its own.
    public let assistant: InteractorAssistantType = .basicAsync

    public let configurationType: ActionConfigurationType = .branch

    /// The output conduit assigned by ``ActionSequenceConfiguration``'s `.conduit()` method, forwarding the selected path's output to the next sequence step.
    public var outputConduit: (any ActionSequenceConduiting<ContentType>)?

    public let identifier: (any ActionIdentifying)?
    public let shouldEndParentTaskOnFailure: Bool
    public let shouldSaveResult: Bool

    /// The ordered list of branch path configurations. Conditions are evaluated in declaration order; the first match is selected.
    public private(set) var cases: [ActionBranchPathConfiguration<InteractorType, ContentType>] = []

    public init(identifier: (any ActionIdentifying)? = nil, shouldEndParentTaskOnFailure: Bool = false, shouldSaveResult: Bool = true) {
        self.identifier = identifier
        self.shouldEndParentTaskOnFailure = shouldEndParentTaskOnFailure
        self.shouldSaveResult = shouldSaveResult
    }

    /// Appends a conditional branch path.
    ///
    /// - Parameters:
    ///   - condition: The ``BranchCondition`` evaluated at runtime to determine whether this path is selected.
    ///   - action: The action configuration to build and run when this branch path is selected.
    ///   - transformer: An optional transformer applied to the branch path's output before forwarding downstream. Required when the path's output shape differs from what the downstream step expects.
    /// - Returns: A copy of this configuration with the branch path appended.
    public func branch(when condition: any BranchConditionable<ContentType>, action: any ActionConfiguring<InteractorType, ContentType>, transformer: (any ContentTransformable<ContentType>)? = nil) -> Self {
        var mutableSelf = self
        mutableSelf.cases.append(ActionBranchPathConfiguration(condition: condition, actionConfig: action, transformer: transformer))
        return mutableSelf
    }
    

    /// Appends an unconditional fallback branch path that runs when no earlier condition matches.
    ///
    /// - Parameters:
    ///   - action: The action configuration to build and run as the fallback.
    ///   - transformer: An optional transformer applied to the fallback branch path's output before forwarding downstream.
    /// - Returns: A copy of this configuration with the fallback branch path appended.
    public func otherwise(_ action: any ActionConfiguring<InteractorType, ContentType>, transformer: (any ContentTransformable<ContentType>)? = nil) -> Self {
        var mutableSelf = self
        mutableSelf.cases.append(ActionBranchPathConfiguration(condition: AlwaysTrueCondition(), actionConfig: action, transformer: transformer))
        return mutableSelf
    }
    
    /// Appends an unconditional fallback branch path backed by a built-in result-handling behavior.
    ///
    /// Use `.skip` to complete silently when no earlier condition matched, or `.fail` to stop the sequence and return a Result `.failure` with the accumulated partial results.
    ///
    /// - Parameter resultHandling: The built-in behavior to apply as the fallback.
    /// - Returns: A copy of this configuration with the fallback branch path appended.
    public func otherwise(_ resultHandling: BranchResultHandlingType) -> Self {
        var mutableSelf = self
        mutableSelf.cases.append(ActionBranchPathConfiguration(condition: AlwaysTrueCondition(), actionConfig: buildActionConfig(for: resultHandling), transformer: nil))
        return mutableSelf
    }

    private func buildActionConfig(for handling: BranchResultHandlingType) -> any ActionConfiguring<InteractorType, ContentType> {
        switch handling {
            case .skip:
                return SkipActionConfig<InteractorType, ContentType>()
            case .fail:
                return FailActionConfig<InteractorType, ContentType>()
        }
    }

    public func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {
        let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
        let message = String(format: template, "\(actionType)")
        throw DestinationsError.unsupportedInteractorAssistantType(message: message)
    }

    /// Builds the ``ActionBranch`` by constructing a ``BranchConditionable`` object for each branch path configuration.
    public func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        let builtCases: [ActionBranchPath<ContentType>] = try cases.map { caseConfig in
            let action = try caseConfig.actionConfig.buildAction(resultHandler: resultHandler)
            return ActionBranchPath(condition: caseConfig.condition, action: action, transformer: caseConfig.transformer)
        }
        return ActionBranch(cases: builtCases, identifier: identifier, outputConduit: outputConduit, shouldEndParentTaskOnFailure: shouldEndParentTaskOnFailure, shouldSaveResult: shouldSaveResult)
    }
}

@MainActor private struct AlwaysTrueCondition<C: ContentTypeable>: BranchConditionable {
    func evaluate(content: C?) -> Bool { true }
}

// MARK: - Built-in action configs

@MainActor private struct FailActionConfig<InteractorType: InteractorTypeable, ContentType: ContentTypeable>: ActionConfiguring {
    enum ActionType: InteractorRequestActionTypeable { case fail }
    let actionType: ActionType = .fail
    let assistant: InteractorAssistantType = .basicAsync
    let configurationType: ActionConfigurationType = .interactor
    var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    let identifier: (any ActionIdentifying)? = nil
    let shouldEndParentTaskOnFailure: Bool = false
    let shouldSaveResult: Bool = false

    func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {
        let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
        throw DestinationsError.unsupportedInteractorAssistantType(message: String(format: template, "\(actionType)"))
    }

    func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        FailBranchAction<ContentType>()
    }
}

@MainActor private struct SkipActionConfig<InteractorType: InteractorTypeable, ContentType: ContentTypeable>: ActionConfiguring {
    enum ActionType: InteractorRequestActionTypeable { case skip }
    let actionType: ActionType = .skip
    let assistant: InteractorAssistantType = .basicAsync
    let configurationType: ActionConfigurationType = .interactor
    var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    let identifier: (any ActionIdentifying)? = nil
    let shouldEndParentTaskOnFailure: Bool = false
    let shouldSaveResult: Bool = false

    func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {
        let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
        throw DestinationsError.unsupportedInteractorAssistantType(message: String(format: template, "\(actionType)"))
    }

    func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        SkipBranchAction<ContentType>()
    }
}

// MARK: - Built-in action performables

@MainActor private final class FailBranchAction<ContentType: ContentTypeable>: ActionPerformable {
    let id = UUID()
    var actionType: (any InteractorRequestActionTypeable)? { nil }
    var identifier: (any ActionIdentifying)? { nil }
    var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    var shouldEndParentTaskOnFailure: Bool = false
    var shouldSaveResult: Bool = false

    func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error> {
        .failure(ActionError<ContentType>.cancelled(partialResults: sequenceOutputs))
    }
}

@MainActor private final class SkipBranchAction<ContentType: ContentTypeable>: ActionPerformable {
    let id = UUID()
    var actionType: (any InteractorRequestActionTypeable)? { nil }
    var identifier: (any ActionIdentifying)? { nil }
    var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    var shouldEndParentTaskOnFailure: Bool = false
    var shouldSaveResult: Bool = false

    func perform(with content: ContentType?, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, any Error> {
        .success(sequenceOutputs)
    }
}

/// Specifies the built-in fallback behavior for a branch path that runs no action.
public enum BranchResultHandlingType {
    /// Complete silently and let the sequence continue. The branch contributes no result to the outputs.
    case skip
    /// Fail the sequence with the partial results accumulated so far.
    case fail
}
