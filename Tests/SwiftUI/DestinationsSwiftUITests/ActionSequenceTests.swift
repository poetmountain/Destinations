//
//  ActionSequenceTests.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class ActionSequenceTests: XCTestCase, DestinationTypes {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
        continueAfterFailure = false
    }

    // MARK: - Destinationable.performActions(for:content:)

    func test_performActionSequence_returns_responses_for_all_steps() async throws {
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )
            .output()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .paginate,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: ColorsDatasource())

        let result = await destination.performActions(for: .retrieveInitialColors)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 2, "Expected a response for each of the two steps, got \(responses.results.count)")

                if let action = responses.results.first?.action as? ColorsDatasource.Request.ActionType {
                    XCTAssertEqual(action, .retrieve)
                } else {
                    XCTFail("Expected action type to be ColorsDatasource.Request.ActionType, but it is \(type(of: responses.results.first?.action))")
                }

                if let action = responses.results.last?.action as? ColorsDatasource.Request.ActionType {
                    XCTAssertEqual(action, .paginate)
                } else {
                    XCTFail("Expected action type to be ColorsDatasource.Request.ActionType, but it is \(type(of: responses.results.last?.action))")
                }

                if case .colors(models: let models) = responses.results.last?.content {
                    XCTAssertGreaterThan(models.count, 0, "Expected the last response to contain color models")
                } else {
                    XCTFail("Expected .colors content in the last response, got \(String(describing: responses.results.last?.content))")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the sequence's task to be removed from the internal state after completing")
    }

    func test_performActionSequence_returns_interactorNotFound_when_no_configuration() async {
        let destination = ColorsListView.Destination(destinationType: .colorsList)

        let result = await destination.performActions(for: .retrieveInitialColors)

        switch result {
            case .success:
                XCTFail("Expected failure when no ActionSequenceConfiguration is registered for the event type")
            case .failure(let error):
                if case DestinationsError.interactorNotFound = error {
                    // success
                } else {
                    XCTFail("Expected interactorNotFound failure, got \(error)")
                }
        }
    }

    func test_performActionSequence_returns_noActionsAvailable_when_sequence_is_empty() async {
        let sequenceConfiguration = ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: ColorsDatasource())

        let result = await destination.performActions(for: .retrieveInitialColors)

        switch result {
            case .success:
                XCTFail("Expected failure when the sequence configuration contains no actions")
            case .failure(let error):
                if case ActionError<AppContentType>.noActionsAvailable = error {
                    // success
                } else {
                    XCTFail("Expected noActionsAvailable failure, got \(error)")
                }
        }
    }

    // MARK: - Destinationable.performActions(configuration:)

    func test_performActionSequence_configuration_returns_responses_for_all_steps() async throws {
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )
            .output()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .paginate,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 2, "Expected a response for each of the two steps, got \(responses.results.count)")

                if let action = responses.results.first?.action as? ColorsDatasource.Request.ActionType {
                    XCTAssertEqual(action, .retrieve)
                } else {
                    XCTFail("Expected action type to be ColorsDatasource.Request.ActionType, but it is \(type(of: responses.results.first?.action))")
                }

                if let action = responses.results.last?.action as? ColorsDatasource.Request.ActionType {
                    XCTAssertEqual(action, .paginate)
                } else {
                    XCTFail("Expected action type to be ColorsDatasource.Request.ActionType, but it is \(type(of: responses.results.last?.action))")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the sequence's task to be removed from the internal state after completing")
    }

    func test_nonterminal_action_shouldSaveResult_false_excludes_from_results_but_still_forwards_content() async throws {
        // A non-terminal Action's shouldSaveResult: false should exclude its own result from the
        // sequence's outputs, but must not prevent its content from flowing to the next step.
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve,
                assistant: .custom(RedBranchAssistant()), identifier: nil, shouldSaveResult: false))
            .output()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve,
                assistant: .custom(EchoContentAssistant()), identifier: nil))

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected only the second step's result; the first step opted out via shouldSaveResult: false, got \(responses.results.count)")

                guard let finalResult = responses.results.first else {
                    XCTFail("Expected a result")
                    return
                }
                if case .colors(models: let models) = finalResult.content {
                    XCTAssertEqual(models.first?.name, "red-branch", "Expected the second step to receive the first step's content, forwarded despite shouldSaveResult: false")
                } else {
                    XCTFail("Expected .colors content, got \(finalResult.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success, got failure: \(error)")
        }
    }

    func test_performActionSequence_configuration_returns_interactorNotFound_when_interactor_not_registered() async throws {
        // Sequence references the `.colors` interactor but no interactor is registered on the destination.
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = ColorsListView.Destination(destinationType: .colorsList)

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected pre-flight failure when the required interactor is not registered")
            case .failure(let error):
                if case DestinationsError.unregisteredInteractor = error {
                    // success: pre-flight caught the missing interactor before any step ran
                } else {
                    XCTFail("Expected interactorNotFound failure, got \(error)")
                }
        }
    }

    func test_performActionSequence_configuration_returns_interactorNotFound_for_missing_interactor_in_branch() async throws {
        // Branch path references `.colors` but no interactor is registered; confirms the walk descends into branch cases.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors,
                    action: .retrieve,
                    assistant: .basicAsync,
                    identifier: nil)
            )

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = ColorsListView.Destination(destinationType: .colorsList)

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected pre-flight failure when a branch path's interactor is not registered")
            case .failure(let error):
                if case DestinationsError.unregisteredInteractor = error {
                    // success
                } else {
                    XCTFail("Expected interactorNotFound failure, got \(error)")
                }
        }
    }

    func test_performActionSequence_configuration_returns_noActionsAvailable_when_sequence_is_empty() async {
        let sequenceConfiguration = ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected failure when the sequence configuration contains no actions")
            case .failure(let error):
                if case ActionError<AppContentType>.noActionsAvailable = error {
                    // success
                } else {
                    XCTFail("Expected noActionsAvailable failure, got \(error)")
                }
        }
    }

    func test_performActionSequence_configuration_task_cancel_returns_cancelled_error_with_partial_responses() async throws {
        let datasource = GatedColorsDatasource()
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, GatedColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = buildInteractorDestination(interactor: datasource)

        let sequenceTask = Task {
            await destination.performActions(configuration: sequenceConfiguration)
        }

        await datasource.waitUntilRequestStarts()
        sequenceTask.cancel()
        await datasource.openGate()

        let result = await sequenceTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after the task was cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected the response of the step which completed before cancellation, got \(partialResults.results.count) responses")
                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the sequence's task to be removed from the internal state after cancellation")
    }

    // MARK: - ActionSequenceConfiguration building

    func test_step_throws_missingConduit_when_previous_step_has_no_conduit() {
        // The first step has no output conduit, so a second step cannot be chained to it.
        XCTAssertThrowsError(
            try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
                .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors,
                    action: .retrieve,
                    assistant: .basicAsync,
                    identifier: nil)
                )
                .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors,
                    action: .paginate,
                    assistant: .basicAsync,
                    identifier: nil)
                )
        ) { error in
            if case ActionError<AppContentType>.missingConduit = error {
                // success
            } else {
                XCTFail("Expected missingConduit error, got \(error)")
            }
        }
    }

    func test_conduit_throws_missingAction_when_sequence_has_no_steps() {
        // A conduit can only be attached to a previously added step.
        XCTAssertThrowsError(
            try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
                .output()
        ) { error in
            if case ActionError<AppContentType>.missingAction = error {
                // success
            } else {
                XCTFail("Expected missingAction error, got \(error)")
            }
        }
    }

    // MARK: - Group steps

    func test_performActionSequence_group_step_records_single_group_response_with_child_responses() async throws {
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup)

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(group)

        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: ColorsDatasource())

        let result = await destination.performActions(for: .retrieveInitialColors)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected the group to contribute a single response, got \(responses.results.count)")

                guard let groupResponse = responses.results.first else {
                    XCTFail("Expected a group response")
                    return
                }

                if case .group(results: let childResults) = groupResponse.origin {
                    XCTAssertEqual(childResults?.count, 2, "Expected two child responses, got \(childResults?.count ?? 0)")
                } else {
                    XCTFail("Expected a group origin, got \(groupResponse.origin)")
                }

                if case .colors(models: let models) = groupResponse.content {
                    XCTAssertGreaterThan(models.count, 0, "Expected the merged group content to contain color models")
                } else {
                    XCTFail("Expected merged .colors content, got \(groupResponse.content as Any)")
                }

                XCTAssertEqual(responses.results(matching: GroupTestStep.retrieveGroup).count, 1, "Expected to locate the group response by its step type")

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_performActionSequence_group_child_with_shouldEndParentTaskOnFailure_cancels_siblings_gate_pattern() async throws {
        // Gate pattern: GateController coordinates two things:
        //   1. Child C signals when it has started, so the test knows it is a live sibling.
        //   2. Child B waits behind a gate; the test opens it only after Child C has started,
        //      so Child B's failure — and the resulting group.cancelAll() — is guaranteed to
        //      happen while Child C is already running.
        let gate = GateController()

        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(ImmediateSuccessGroupAssistant()),
                    identifier: nil),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(GatedFailingGroupAssistant(gate: gate)),
                    identifier: nil,
                    shouldEndParentTaskOnFailure: true),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(GatedSlowGroupAssistant(gate: gate)),
                    identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: nil)

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(group)

        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: ColorsDatasource())

        // Start the sequence in an unstructured task so the gate coordination below can run concurrently
        let sequenceTask = Task {
            await destination.performActions(for: .retrieveInitialColors)
        }

        // Waits here until Child C signals it has started
        await gate.waitUntilChildStarted()

        // Opens the gate so Child B can now return its failure, triggering the group.cancelAll() which cancels Child C
        await gate.open()

        let result = await sequenceTask.value

        switch result {
            case .success:
                XCTFail("Expected the sequence to fail when a group child with shouldEndParentTaskOnFailure fails")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one group-level partial result, got \(partialResults.results.count)")
                    if case .group(results: let childResults) = partialResults.results.first?.origin {
                        // One child succeeded before the failure, one failed
                        XCTAssertEqual(childResults?.count, 2, "Expected child results for both the completed child and the failing child, got \(childResults?.count ?? 0)")
                        let hasFailure = childResults?.contains(where: {
                            if case .failure = $0.result { return true }
                            return false
                        }) ?? false
                        XCTAssertTrue(hasFailure, "Expected at least one child result to carry the failure")
                    } else {
                        XCTFail("Expected a group origin on the partial result, got \(String(describing: partialResults.results.first?.origin))")
                    }
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the sequence's task to be removed from the internal state after failure")
    }

    // MARK: - Nested composition

    func test_group_child_can_be_a_branch() async throws {
        // A branch can be used as one of a group's parallel children, not just as a top-level sequence step.
        let branchChild = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))

        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                branchChild,
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success(let responses):
                guard let groupResponse = responses.results.first, case .colors(models: let models) = groupResponse.content else {
                    XCTFail("Expected merged .colors content")
                    return
                }
                XCTAssertEqual(models.count, 2, "Expected both the branch child's and the plain action child's results merged, got \(models.count)")
                XCTAssertTrue(models.contains(where: { $0.name == "blue-branch" }), "Expected the branch child's content in the merge")
                XCTAssertTrue(models.contains(where: { $0.name == "red-branch" }), "Expected the plain action child's content in the merge")

            case .failure(let error):
                XCTFail("Expected success, got failure: \(error)")
        }
    }

    func test_branch_path_can_be_a_group() async throws {
        // A group can be used as a branch path's action, not just as a top-level sequence step.
        let groupChild = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: nil),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup)

        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(when: BooleanCondition(true), action: groupChild)

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected a single branch-level result wrapping the group's merged content, got \(responses.results.count)")

                guard let branchResult = responses.results.first, case .colors(models: let models) = branchResult.content else {
                    XCTFail("Expected merged .colors content")
                    return
                }
                XCTAssertEqual(models.count, 2, "Expected the group's merged content (from both children) to flow through as the branch's result, got \(models.count)")

            case .failure(let error):
                XCTFail("Expected success, got failure: \(error)")
        }
    }

    // MARK: ActionBranch tests

    func test_branch_selects_first_matching_path() async throws {
        // Both paths use BooleanCondition(true) so both would match, but only the first path
        // (BlueBranchAssistant) should run. Verifies that conditions are evaluated in order and the
        // first match wins.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 2, "Expected 2 results (retrieve + branch), got \(responses.results.count)")

                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.bluePath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected the first matching path (blue) to win")
                } else {
                    XCTFail("Expected .colors content in the branch result, got \(branchResult.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_branch_records_result_with_branch_origin() async throws {
        // A branch's own recorded result should carry origin .branch, not .none, so callers can
        // distinguish a branch-produced result from a plain action result.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.bluePath")
                    return
                }
                if case .branch = branchResult.origin {
                    // success
                } else {
                    XCTFail("Expected the branch's recorded result to carry origin .branch, got \(branchResult.origin)")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_branch_runs_otherwise_fallback_when_no_condition_matches() async throws {
        // BooleanCondition(false) never matches, so the .otherwise fallback (RedBranchAssistant) runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: BooleanCondition(false),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.redPath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.redPath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .red, "Expected the otherwise fallback (red) to run when no condition matched")
                } else {
                    XCTFail("Expected .colors content from the fallback path, got \(branchResult.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_branch_fails_with_cancelled_when_no_condition_matches_and_content_is_nil() async throws {
        // The branch is the first step so it receives nil content. BooleanCondition(false) never
        // matches and there is no otherwise fallback, so the branch fails with .cancelled.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(false),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: nil))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected failure when no branch condition matches and content is nil")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 0, "Expected no partial results when the branch itself fails before any path runs")
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }
    }

    func test_branch_succeeds_as_noop_when_no_condition_matches_and_content_is_non_nil() async throws {
        // Unlike the nil-content case above (which fails with .cancelled), when no condition matches,
        // there's no .otherwise fallback, but content IS present, so the branch succeeds silently as a
        // no-op: it contributes no new result and passes through the prior accumulated outputs unchanged.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(false),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected only the retrieve result; a non-matching branch with no fallback should contribute nothing, got \(responses.results.count)")
            case .failure(let error):
                XCTFail("Expected success (silent no-op) when no condition matches, there's no fallback, but content is non-nil, got failure: \(error)")
        }
    }

    func test_branch_terminal_safety_net_saves_result_despite_shouldSaveResult_false() async throws {
        // Even when the branch's own shouldSaveResult is false, if the branch is the last step of
        // the sequence (no outputConduit), its result is still recorded. Otherwise the selected path's
        // content would be unrecoverable to the caller.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(shouldSaveResult: false)
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil, shouldSaveResult: false))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected the branch's own result to be force-saved despite shouldSaveResult: false, since it's the terminal step, got \(responses.results.count)")

                guard let branchResult = responses.results.last else {
                    XCTFail("Expected a branch result")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected the matched path's content to be preserved")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success, got failure: \(error)")
        }
    }

    // MARK: BranchResultHandlingType tests

    func test_otherwise_skip_contributes_no_result_when_no_condition_matches() async throws {
        // For this test the branch condition doesn't match and so the .otherwise(.skip) runs. Skip contributes no result, so the sequence succeeds with only the prior retrieve result.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(false),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(.skip)

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected only the retrieve result; .otherwise(.skip) should contribute no result, got \(responses.results.count)")
            case .failure(let error):
                XCTFail("Expected success when fallback uses .skip, got failure: \(error)")
        }
    }

    func test_otherwise_skip_forwards_content_to_next_step_when_branch_has_output_conduit() async throws {
        // For this test the branch condition doesn't match and so the .otherwise(.skip) runs. Because the branch has an output
        // conduit (via `.output()`), the sequence should continue to the step after it, which should
        // receive the same content that was passed into the branch, unchanged.
        // The branch itself will still contribute no result of its own to the outputs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(false),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(.skip)

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve,
                assistant: .custom(RedBranchAssistant()), identifier: nil))
            .output()
            .step(branchConfig)
            .output()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve,
                assistant: .custom(EchoContentAssistant()), identifier: BranchTestStep.postSkipStep))

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 2, "Expected the initial retrieve result and the post-branch step's result; .otherwise(.skip) should contribute none of its own, got \(responses.results.count)")

                guard let finalResult = responses.last(identifier: BranchTestStep.postSkipStep) else {
                    XCTFail("Expected the step after the skipped branch to run and record a result")
                    return
                }
                if case .colors(models: let models) = finalResult.content {
                    XCTAssertEqual(models.first?.name, "red-branch", "Expected the step after the skip to receive the original pre-branch content, forwarded unchanged")
                } else {
                    XCTFail("Expected .colors content forwarded to the step after the skip, got \(finalResult.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success when .skip forwards to a subsequent step, got failure: \(error)")
        }
    }

    func test_otherwise_fail_returns_cancelled_with_partial_results_when_no_condition_matches() async throws {
        // For this test the branch condition doesn't match so .otherwise(.fail) runs. It fails the sequence with the results accumulated before the branch (the retrieve step result).
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(false),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(.fail)

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected failure when fallback uses .fail")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one partial result from the retrieve step that completed before .fail, got \(partialResults.results.count)")
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }
    }

    // MARK: AllSatisfyCondition tests

    func test_groupCondition_selects_path_when_all_child_conditions_match() async throws {
        // All children are BooleanCondition(true) → AllSatisfyCondition evaluates to true → blue path runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AllSatisfyCondition(conditions: [BooleanCondition(true), BooleanCondition(true)]),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.bluePath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected AllSatisfyCondition (all true) to select the blue path")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_groupCondition_skips_path_when_any_child_condition_fails() async throws {
        // One child is false → AllSatisfyCondition evaluates to false → blue path skipped, otherwise (red) runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AllSatisfyCondition(conditions: [BooleanCondition(true), BooleanCondition(false)]),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.redPath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.redPath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .red, "Expected AllSatisfyCondition (one child false) to fall through to otherwise")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_groupCondition_negated_selects_path_when_group_fails() async throws {
        // All children are false → AllSatisfyCondition evaluates to false → .negated() inverts to true → blue path runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AllSatisfyCondition(conditions: [BooleanCondition(false), BooleanCondition(false)]).negated(),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.bluePath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected negated AllSatisfyCondition with all-false children to select the blue path")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_groupCondition_with_empty_conditions_selects_path() async throws {
        // No children → evaluate returns true by default → blue path runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AllSatisfyCondition(conditions: []),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.bluePath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected AllSatisfyCondition with no children to vacuously pass (select blue path)")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    // MARK: - .negated() tests

    func test_negated_condition_selects_path_when_original_evaluates_false() async throws {
        // BooleanCondition(false) would not select this path. .negated() inverts it → true → blue path runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: BooleanCondition(false).negated(),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected blue path to be selected via .negated() on a false condition")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected .negated() on BooleanCondition(false) to select the blue path")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_negated_condition_skips_path_when_original_evaluates_true() async throws {
        // BooleanCondition(true) would select this path. .negated() inverts it → false → falls to otherwise (red).
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: BooleanCondition(true).negated(),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.redPath) else {
                    XCTFail("Expected red otherwise path to run when .negated() on a true condition blocks the first path")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .red, "Expected .negated() on BooleanCondition(true) to fall through to the otherwise path")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    // MARK: - AnySatisfyCondition tests

    func test_anyCondition_selects_path_when_one_child_passes() async throws {
        // First child is false, second is true → AnySatisfyCondition passes → blue path runs.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AnySatisfyCondition(conditions: [BooleanCondition(false), BooleanCondition(true)]),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected blue path to be selected when at least one AnySatisfyCondition child passes")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .blue, "Expected AnySatisfyCondition to select the blue path when one child passes")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_anyCondition_skips_path_when_all_children_fail() async throws {
        // All children are false → AnySatisfyCondition fails → falls to otherwise (red).
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AnySatisfyCondition(conditions: [BooleanCondition(false), BooleanCondition(false)]),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.redPath) else {
                    XCTFail("Expected red otherwise path to run when all AnySatisfyCondition children fail")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .red, "Expected AnySatisfyCondition with all-false children to fall through to otherwise")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_anyCondition_with_empty_conditions_skips_path() async throws {
        // No children → evaluate returns false by default → AnySatisfyCondition fails → falls to otherwise (red).
        // This is the dual of AllSatisfyCondition's empty case, which vacuously passes.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: AnySatisfyCondition(conditions: []),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath))
            .otherwise(
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: BranchTestStep.redPath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.redPath) else {
                    XCTFail("Expected red otherwise path to run when AnySatisfyCondition has no children")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .red, "Expected empty AnySatisfyCondition to vacuously fail and fall through to otherwise")
                } else {
                    XCTFail("Expected .colors content, got \(branchResult.content as Any)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_branch_applies_transformer_to_selected_path_result() async throws {
        // BooleanCondition(true) matches, running BlueBranchAssistant. GreenColorTransformer
        // converts the blue result — the branch should record the green output, not the raw blue.
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>(
                identifier: BranchTestStep.retrieveBranch)
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: BranchTestStep.bluePath),
                transformer: GreenColorTransformer())

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil))
            .output()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let branchResult = responses.last(identifier: BranchTestStep.bluePath) else {
                    XCTFail("Expected the branch to record a result with the winning path's identifier BranchTestStep.bluePath")
                    return
                }
                if case .colors(models: let models) = branchResult.content {
                    XCTAssertEqual(models.first?.color, .green, "Expected the transformer to produce green output")
                } else {
                    XCTFail("Expected .colors content after transformation, got \(branchResult.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    // MARK: - ActionGroupConfiguration as top-level collection

    func test_performActions_group_configuration_returns_merged_response() async throws {
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected the group to contribute a single response, got \(responses.results.count)")

                guard let groupResponse = responses.results.first else {
                    XCTFail("Expected a group response")
                    return
                }

                if case .group(results: let childResults) = groupResponse.origin {
                    XCTAssertEqual(childResults?.count, 2, "Expected two child responses, got \(childResults?.count ?? 0)")
                } else {
                    XCTFail("Expected a group origin, got \(groupResponse.origin)")
                }

                if case .colors(models: let models) = groupResponse.content {
                    XCTAssertGreaterThan(models.count, 0, "Expected the merged group content to contain color models")
                } else {
                    XCTFail("Expected merged .colors content, got \(groupResponse.content as Any)")
                }

                XCTAssertEqual(responses.results(matching: GroupTestStep.retrieveGroup).count, 1, "Expected to locate the group response by its identifier")

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the group's task to be removed from the internal state after completing")
    }

    func test_performActions_group_configuration_terminal_safety_net_saves_result_despite_shouldSaveResult_false() async throws {
        // Even when the group's own shouldSaveResult is false, a group passed directly to performActions(configuration:) has no outputConduit (it's the last step) so its merged result is still recorded. Otherwise the merged content would be unrecoverable to the caller.
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup,
            shouldSaveResult: false)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected the group's own result to be force-saved despite shouldSaveResult: false, since it's the terminal step, got \(responses.results.count)")

                if case .colors(models: let models) = responses.results.first?.content {
                    XCTAssertGreaterThan(models.count, 0, "Expected the merged content to be present")
                } else {
                    XCTFail("Expected merged .colors content, got \(responses.results.first?.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success, got failure: \(error)")
        }
    }

    func test_performActions_group_excludes_child_with_shouldSaveResult_false_from_merge() async throws {
        // A child with shouldSaveResult = false should be excluded from the group's merge entirely, not merely omitted from bookkeeping, even if it completed successfully.
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(BlueBranchAssistant()), identifier: nil, shouldSaveResult: true),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(RedBranchAssistant()), identifier: nil, shouldSaveResult: false)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success(let responses):
                guard let groupResponse = responses.results.first else {
                    XCTFail("Expected a group response")
                    return
                }

                if case .group(results: let childResults) = groupResponse.origin {
                    XCTAssertEqual(childResults?.count, 1, "Expected only the child with shouldSaveResult: true to appear in the group's child breakdown, got \(childResults?.count ?? 0)")
                } else {
                    XCTFail("Expected a group origin, got \(groupResponse.origin)")
                }

                if case .colors(models: let models) = groupResponse.content {
                    XCTAssertEqual(models.count, 1, "Expected the merge to exclude the child with shouldSaveResult: false, got \(models.count)")
                    XCTAssertEqual(models.first?.name, "blue-branch", "Expected only the shouldSaveResult: true child's content in the merge")
                } else {
                    XCTFail("Expected merged .colors content, got \(groupResponse.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_performActions_group_shouldSaveChildResults_false_omits_child_breakdown_but_keeps_full_merge() async throws {
        // shouldSaveChildResults only affects the child breakdown recorded in the group's origin; it should not affect which children contribute to the merged content.
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: GroupTestStep.retrieveGroup,
            shouldSaveChildResults: false)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success(let responses):
                guard let groupResponse = responses.results.first else {
                    XCTFail("Expected a group response")
                    return
                }

                if case .group(results: let childResults) = groupResponse.origin {
                    XCTAssertEqual(childResults?.count, 0, "Expected no child breakdown when shouldSaveChildResults is false, got \(childResults?.count ?? -1)")
                } else {
                    XCTFail("Expected a group origin, got \(groupResponse.origin)")
                }

                if case .colors(models: let models) = groupResponse.content {
                    XCTAssertGreaterThan(models.count, 0, "Expected the merged content to still include both children's results")
                } else {
                    XCTFail("Expected merged .colors content, got \(groupResponse.content as Any)")
                }

            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_performActions_group_configuration_returns_noActionsAvailable_when_empty() async {
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [],
            merger: ColorsGroupMerger(),
            identifier: nil)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success:
                XCTFail("Expected failure when the group configuration contains no actions")
            case .failure(let error):
                if case ActionError<AppContentType>.noActionsAvailable = error {
                    // success
                } else {
                    XCTFail("Expected noActionsAvailable failure, got \(error)")
                }
        }
    }

    func test_performActions_group_configuration_task_cancel_returns_cancelled_error_with_partial_responses() async throws {
        let datasource = GatedColorsDatasource()
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, GatedColorsDatasource>(
                    interactorType: .colors,
                    action: .retrieve,
                    assistant: .basicAsync,
                    identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: nil)

        let destination = buildInteractorDestination(interactor: datasource)

        let groupTask = Task {
            await destination.performActions(configuration: group)
        }

        await datasource.waitUntilRequestStarts()
        groupTask.cancel()
        await datasource.openGate()

        let result = await groupTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after the task was cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected the completed child's result in partial results, got \(partialResults.results.count)")
                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the group's task to be removed from the internal state after cancellation")
    }

    func test_group_child_cancelled_still_saves_completed_children_results() async throws {
        // Test of previous bug that would drop in-flight completed results when a child's Task is cancelled
        let gateA = GateController()
        let gateB = GateController()

        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                UncancellableSuccessActionConfig(gate: gateA, colorModel: ColorViewModel(colorID: UUID(), color: .blue, name: "blue")),
                UncancellableSuccessActionConfig(gate: gateB, colorModel: ColorViewModel(colorID: UUID(), color: .red, name: "red"))
            ],
            merger: ColorsGroupMerger(),
            identifier: nil)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let groupTask = Task {
            await destination.performActions(configuration: group)
        }

        await gateA.waitUntilChildStarted()
        await gateB.waitUntilChildStarted()
        groupTask.cancel()
        await gateA.open()
        await gateB.open()

        let result = await groupTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after the task was cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1)
                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }
    }

    func test_performActions_group_configuration_cancelAllActionSequences_cancels_group() async throws {
        let datasource = GatedColorsDatasource()
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, GatedColorsDatasource>(
                    interactorType: .colors,
                    action: .retrieve,
                    assistant: .basicAsync,
                    identifier: nil)
            ],
            merger: ColorsGroupMerger(),
            identifier: nil)

        let destination = buildInteractorDestination(interactor: datasource)

        let groupTask = Task {
            await destination.performActions(configuration: group)
        }

        await datasource.waitUntilRequestStarts()
        destination.cancelAllActionSequences()
        await datasource.openGate()

        let result = await groupTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after all action collections were cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled = error {
                    // success
                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }
    }

    // MARK: - Cancellation

    func test_task_cancel_returns_cancelled_error_with_partial_responses() async throws {
        let datasource = GatedColorsDatasource()
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, GatedColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: datasource)

        let sequenceTask = Task {
            await destination.performActions(for: .retrieveInitialColors)
        }

        // Cancel while the step's interactor request is in progress, then let the request finish so the step's post-request cancellation check is what fails the sequence
        await datasource.waitUntilRequestStarts()
        sequenceTask.cancel()
        await datasource.openGate()

        let result = await sequenceTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after the sequence was cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected the response of the step which completed before cancellation, got \(partialResults.results.count) responses")
                    if let firstResponse = partialResults.results.first {
                        if case .colors(models: let colors) = firstResponse.content {
                            XCTAssertEqual(colors.first?.color, .red)
                        } else {
                            XCTFail("Expected to get color models, but got \(firstResponse.content as Any)")
                        }

                        if let action = firstResponse.action as? ColorsDatasource.Request.ActionType {
                            XCTAssertEqual(action, .retrieve)
                        } else {
                            XCTFail("Expected action type to be ColorsDatasource.Request.ActionType, but it is \(type(of: firstResponse.action))")
                        }
                    }

                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }

        XCTAssertTrue(destination.internalState.activeSequenceTasks.isEmpty, "Expected the sequence's task to be removed from the internal state after cancellation")
    }

    func test_branch_cancellation_returns_cancelled_error_with_partial_results() async throws {
        // Cancel while the matched path's interactor request is in progress, then let it finish, so a post-request cancellation check somewhere along the branch's path is what fails the sequence.
        let datasource = GatedColorsDatasource()
        let branchConfig = ActionBranchConfiguration<ColorsListView.InteractorType, AppContentType>()
            .branch(
                when: BooleanCondition(true),
                action: ActionConfiguration<ColorsListView.InteractorType, AppContentType, GatedColorsDatasource>(
                    interactorType: .colors, action: .retrieve, assistant: .basicAsync, identifier: BranchTestStep.bluePath))

        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(branchConfig)

        let destination = buildInteractorDestination(interactor: datasource)

        let sequenceTask = Task {
            await destination.performActions(configuration: sequenceConfiguration)
        }

        await datasource.waitUntilRequestStarts()
        sequenceTask.cancel()
        await datasource.openGate()

        let result = await sequenceTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after the task was cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected the matched path's completed result in partial results, got \(partialResults.results.count)")
                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }
    }

    func test_cancelAllActionSequences_cancels_running_sequence() async throws {
        let datasource = GatedColorsDatasource()
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, GatedColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: datasource)

        let sequenceTask = Task {
            await destination.performActions(for: .retrieveInitialColors)
        }

        await datasource.waitUntilRequestStarts()
        destination.cancelAllActionSequences()
        await datasource.openGate()

        let result = await sequenceTask.value

        switch result {
            case .success:
                XCTFail("Expected failure after all sequences were cancelled")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled = error {
                    // success
                } else {
                    XCTFail("Expected cancelled failure, got \(error)")
                }
        }
    }

    func test_cancelAllActionSequences_with_no_running_sequence_has_no_effect() async throws {
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: nil)
            )

        let destination = buildSequenceDestination(sequenceConfiguration: sequenceConfiguration, interactor: ColorsDatasource())

        // No sequence is running, so this is a no-op
        destination.cancelAllActionSequences()

        let result = await destination.performActions(for: .retrieveInitialColors)

        switch result {
            case .success(let responses):
                XCTAssertEqual(responses.results.count, 1, "Expected the sequence to run normally after a no-op cancellation")
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    // MARK: - Failure result recording

    func test_action_step_failure_records_failure_result_in_partial_results() async throws {
        // A step that fails should record a failure ActionResult so callers can inspect what went wrong.
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .custom(FailingColorAssistant()),
                identifier: StepFailureIdentifier.failingStep)
            )

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected failure when the step's interactor returns an error")
            case .failure(let error):
                if case ActionError<AppContentType>.failed(partialResults: let partialResults, error: _) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one result for the failed step, got \(partialResults.results.count)")
                    guard let stepResult = partialResults.results.first else {
                        XCTFail("Expected a result for the failed step")
                        return
                    }
                    if case .failure = stepResult.result {
                        // success: the failure was recorded
                    } else {
                        XCTFail("Expected the step result to carry the failure, got \(stepResult.result)")
                    }
                    XCTAssertNil(stepResult.content, "Expected content to be nil for a failed step")
                    let failed = partialResults.failedActions()
                    XCTAssertEqual(failed.count, 1, "Expected failedActions() to return the failed step")
                } else {
                    XCTFail("Expected failed(partialResults:error:) error, got \(error)")
                }
        }
    }

    func test_action_step_failure_exposes_underlying_interactor_error() async throws {
        // The .failed error's `error` associated value should be the original error returned by the interactor.
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .custom(FailingColorAssistant()),
                identifier: StepFailureIdentifier.failingStep)
            )

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected failure when the step's interactor returns an error")
            case .failure(let error):
                if case ActionError<AppContentType>.failed(partialResults: _, error: let underlyingError) = error {
                    XCTAssertTrue(underlyingError is StepAssistantFailureError, "Expected the underlying error to be StepAssistantFailureError, got \(type(of: underlyingError))")
                } else {
                    XCTFail("Expected failed(partialResults:error:) error, got \(error)")
                }
        }
    }

    func test_output_transformer_applies_to_content_between_sequence_steps() async throws {
        // A plain sequence-level .output(using:) transformer should transform content passed between steps, distinct from the branch-level and failure-path transformer tests elsewhere.
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve,
                assistant: .custom(RedBranchAssistant()), identifier: nil))
            .output(using: GreenColorTransformer())
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors, action: .retrieve,
                assistant: .custom(EchoContentAssistant()), identifier: nil))

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success(let responses):
                guard let finalResult = responses.results.last, case .colors(models: let models) = finalResult.content else {
                    XCTFail("Expected .colors content")
                    return
                }
                XCTAssertEqual(models.first?.color, .green, "Expected the transformer to convert the first step's red output to green before it reached the second step")
                XCTAssertEqual(models.first?.name, "green-transformed")

            case .failure(let error):
                XCTFail("Expected success, got failure: \(error)")
        }
    }

    func test_conduit_transformer_failure_returns_failed_error_with_prior_step_results() async throws {
        // When a conduit's transformer throws the sequence should fail with .failed, carrying the partial results from the step that completed before the transformer ran.
        let sequenceConfiguration = try ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>()
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .retrieve,
                assistant: .basicAsync,
                identifier: StepFailureIdentifier.successStep)
            )
            .output(using: FailingTransformer())
            .step(ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                interactorType: .colors,
                action: .paginate,
                assistant: .basicAsync,
                identifier: StepFailureIdentifier.failingStep)
            )

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: sequenceConfiguration)

        switch result {
            case .success:
                XCTFail("Expected failure when a conduit transformer throws")
            case .failure(let error):
                if case ActionError<AppContentType>.failed(partialResults: let partialResults, error: let underlyingError) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one result from the step that completed before the transformer failed, got \(partialResults.results.count)")
                    if case .success = partialResults.results.first?.result {
                        // success: prior step's result was preserved
                    } else {
                        XCTFail("Expected the prior step's result to be a success, got \(String(describing: partialResults.results.first?.result))")
                    }
                    XCTAssertTrue(underlyingError is FailingTransformerError, "Expected the underlying error to be FailingTransformerError, got \(type(of: underlyingError))")
                } else {
                    XCTFail("Expected failed(partialResults:error:) error, got \(error)")
                }
        }
    }

    func test_group_merger_failure_returns_failed_error_with_group_result() async throws {
        // When all group children succeed but the merger throws the sequence should fail with .failed, carrying a group-level ActionResult whose origin includes each child's success result.
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(ImmediateSuccessGroupAssistant()),
                    identifier: StepFailureIdentifier.successStep),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(ImmediateSuccessGroupAssistant()),
                    identifier: StepFailureIdentifier.successStep)
            ],
            merger: FailingMerger(),
            identifier: StepFailureIdentifier.group)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success:
                XCTFail("Expected failure when the group merger throws")
            case .failure(let error):
                if case ActionError<AppContentType>.failed(partialResults: let partialResults, error: let underlyingError) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one group-level result, got \(partialResults.results.count)")
                    if case .group(results: let childResults) = partialResults.results.first?.origin {
                        XCTAssertEqual(childResults?.count, 2, "Expected child results from both successful children, got \(childResults?.count ?? 0)")
                        let allSucceeded = childResults?.allSatisfy { if case .success = $0.result { return true }; return false } ?? false
                        XCTAssertTrue(allSucceeded, "Expected all child results to be successes since only the merger failed")
                    } else {
                        XCTFail("Expected a group origin on the partial result, got \(String(describing: partialResults.results.first?.origin))")
                    }
                    XCTAssertTrue(underlyingError is FailingMergerError, "Expected the underlying error to be FailingMergerError, got \(type(of: underlyingError))")
                } else {
                    XCTFail("Expected failed(partialResults:error:) error, got \(error)")
                }
        }
    }

    func test_group_child_shouldEndParentTaskOnFailure_failure_records_group_result_with_child_results() async throws {
        // A group child that fails with shouldEndParentTaskOnFailure should produce one group-level
        // ActionResult whose child results include both the successful sibling and the failed child.
        //
        // Gate pattern: since ActionGroup only includes results collected up to the moment a fatal
        // failure is observed, and TaskGroup gives no ordering guarantee between children that never
        // suspend, we use a gate to force the success child to complete (and signal that it has) before
        // releasing the failing child. Without this, the two children would race and this test would
        // fail intermittently whenever the failure was observed before the success.
        let gate = GateController()

        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(GatedImmediateSuccessGroupAssistant(gate: gate)),
                    identifier: StepFailureIdentifier.successStep),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(GatedFailingGroupAssistant(gate: gate)),
                    identifier: StepFailureIdentifier.failingStep,
                    shouldEndParentTaskOnFailure: true)
            ],
            merger: ColorsGroupMerger(),
            identifier: StepFailureIdentifier.group)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        // Start the group in an unstructured task so the gate coordination below can run concurrently.
        let groupTask = Task {
            await destination.performActions(configuration: group)
        }

        // Waits here until the success child signals that it has produced its result.
        await gate.waitUntilChildStarted()

        // Opens the gate so the failing child can now return its failure.
        await gate.open()

        let result = await groupTask.value

        switch result {
            case .success:
                XCTFail("Expected failure when a group child with shouldEndParentTaskOnFailure returns an error")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one group-level partial result, got \(partialResults.results.count)")
                    guard let groupResult = partialResults.results.first else {
                        XCTFail("Expected a group-level result")
                        return
                    }
                    if case .failure = groupResult.result {
                        // success: group result carries the failure
                    } else {
                        XCTFail("Expected the group result to carry the failure, got \(groupResult.result)")
                    }
                    if case .group(results: let childResults) = groupResult.origin {
                        XCTAssertEqual(childResults?.count, 2, "Expected child results for the succeeded child and the failing child, got \(childResults?.count ?? 0)")
                        let successCount = childResults?.filter { if case .success = $0.result { return true }; return false }.count ?? 0
                        let failureCount = childResults?.filter { if case .failure = $0.result { return true }; return false }.count ?? 0
                        XCTAssertEqual(successCount, 1, "Expected one successful child result")
                        XCTAssertEqual(failureCount, 1, "Expected one failed child result")
                    } else {
                        XCTFail("Expected a group origin, got \(groupResult.origin)")
                    }
                    XCTAssertEqual(partialResults.failedActions().count, 1, "Expected failedActions() to return the failed group result")
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }
    }

    func test_group_non_fatal_child_failure_completes_all_children_and_records_failure() async throws {
        // A child that fails with shouldEndParentTaskOnFailure: false should not cancel its siblings.
        // All three children should run to completion and every result — including the failure — should
        // appear in the group's child results.
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(ImmediateSuccessGroupAssistant()),
                    identifier: StepFailureIdentifier.successStep),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(FailingColorAssistant()),
                    identifier: StepFailureIdentifier.failingStep,
                    shouldEndParentTaskOnFailure: false),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(ImmediateSuccessGroupAssistant()),
                    identifier: StepFailureIdentifier.successStep)
            ],
            merger: ColorsGroupMerger(),
            identifier: StepFailureIdentifier.group)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success:
                XCTFail("Expected failure when a group child returns an error")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one group-level result, got \(partialResults.results.count)")
                    if case .group(results: let childResults) = partialResults.results.first?.origin {
                        XCTAssertEqual(childResults?.count, 3, "Expected all three children to complete and be recorded, got \(childResults?.count ?? 0)")
                        let successCount = childResults?.filter { if case .success = $0.result { return true }; return false }.count ?? 0
                        let failureCount = childResults?.filter { if case .failure = $0.result { return true }; return false }.count ?? 0
                        XCTAssertEqual(successCount, 2, "Expected two successful child results")
                        XCTAssertEqual(failureCount, 1, "Expected one failed child result")
                    } else {
                        XCTFail("Expected a group origin on the partial result, got \(String(describing: partialResults.results.first?.origin))")
                    }
                    XCTAssertEqual(partialResults.failedActions().count, 1, "Expected failedActions() to return the failed group result")
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }
    }

    func test_failedActions_does_not_recurse_into_group_children() async throws {
        // failedActions() only inspects top-level results; it does not recurse into a group's child
        // results. With two failing children inside one non-fatal group the group contributes a
        // single top-level result, so failedActions() should count 1, not the 2 individually failed
        // children nested inside its .group(results:) origin.
        let group = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(ImmediateSuccessGroupAssistant()),
                    identifier: StepFailureIdentifier.successStep),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(FailingColorAssistant()),
                    identifier: StepFailureIdentifier.failingStep,
                    shouldEndParentTaskOnFailure: false),
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(FailingColorAssistant()),
                    identifier: StepFailureIdentifier.failingStep,
                    shouldEndParentTaskOnFailure: false)
            ],
            merger: ColorsGroupMerger(),
            identifier: StepFailureIdentifier.group)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: group)

        switch result {
            case .success:
                XCTFail("Expected failure when group children return errors")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one group-level result, got \(partialResults.results.count)")

                    if case .group(results: let childResults) = partialResults.results.first?.origin {
                        let failureCount = childResults?.filter { if case .failure = $0.result { return true }; return false }.count ?? 0
                        XCTAssertEqual(failureCount, 2, "Expected two individually failed children nested in the group's origin, got \(failureCount)")
                    } else {
                        XCTFail("Expected a group origin on the partial result, got \(String(describing: partialResults.results.first?.origin))")
                    }

                    XCTAssertEqual(partialResults.failedActions().count, 1, "Expected failedActions() to count only the group's own top-level result, not each of the 2 failed children nested inside it")
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }
    }

    func test_nested_child_group_failure_is_recorded_in_parent_group_result() async throws {
        // An inner group whose child fails with shouldEndParentTaskOnFailure should produce a failure result that is captured by the outer group. The outer group should record one child result for the inner group carrying that failure.
        let innerGroup = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [
                ActionConfiguration<ColorsListView.InteractorType, AppContentType, ColorsDatasource>(
                    interactorType: .colors, action: .retrieve,
                    assistant: .custom(FailingColorAssistant()),
                    identifier: StepFailureIdentifier.failingStep,
                    shouldEndParentTaskOnFailure: true)
            ],
            merger: ColorsGroupMerger(),
            identifier: StepFailureIdentifier.group,
            shouldEndParentTaskOnFailure: true)

        let outerGroup = ActionGroupConfiguration<ColorsListView.InteractorType, AppContentType>(
            actions: [innerGroup],
            merger: ColorsGroupMerger(),
            identifier: nil)

        let destination = buildInteractorDestination(interactor: ColorsDatasource())

        let result = await destination.performActions(configuration: outerGroup)

        switch result {
            case .success:
                XCTFail("Expected failure when a child group fails")
            case .failure(let error):
                if case ActionError<AppContentType>.cancelled(partialResults: let partialResults) = error {
                    XCTAssertEqual(partialResults.results.count, 1, "Expected one outer group-level partial result, got \(partialResults.results.count)")
                    guard let outerGroupResult = partialResults.results.first else {
                        XCTFail("Expected an outer group result")
                        return
                    }
                    if case .failure = outerGroupResult.result {
                        // success: outer group result carries the failure
                    } else {
                        XCTFail("Expected the outer group result to carry the failure, got \(outerGroupResult.result)")
                    }
                    if case .group(results: let childResults) = outerGroupResult.origin {
                        XCTAssertEqual(childResults?.count, 1, "Expected one child result (the failed inner group), got \(childResults?.count ?? 0)")
                        let hasFailure = childResults?.contains(where: { if case .failure = $0.result { return true }; return false }) ?? false
                        XCTAssertTrue(hasFailure, "Expected the inner group's child result to carry the failure")
                    } else {
                        XCTFail("Expected a group origin on the outer group result, got \(outerGroupResult.origin)")
                    }
                    XCTAssertEqual(partialResults.failedActions().count, 1, "Expected failedActions() to return the failed outer group result")
                } else {
                    XCTFail("Expected cancelled(partialResults:) error, got \(error)")
                }
        }
    }

    // MARK: - Helpers

    /// Builds a `ColorsListView.Destination` with the supplied datasource assigned as the `.colors` interactor,
    /// without registering any sequence configuration for an event type.
    private func buildInteractorDestination(interactor: any AbstractInteractable<ColorsRequest>) -> ColorsListView.Destination {
        let destination = ColorsListView.Destination(destinationType: .colorsList)
        destination.assignInteractor(interactor, to: .colors)
        return destination
    }

    /// Builds a `ColorsListView.Destination` with the supplied action sequence registered for the
    /// `.retrieveInitialColors` event type, and the supplied datasource assigned as the `.colors` interactor.
    private func buildSequenceDestination(sequenceConfiguration: ActionSequenceConfiguration<ColorsListView.InteractorType, AppContentType>, interactor: any AbstractInteractable<ColorsRequest>) -> ColorsListView.Destination {

        let configs = AppDestinationConfigurations<ColorsListView.EventType, DestinationType, ContentType, TabType>()
        configs.addInteractorConfiguration(configuration: sequenceConfiguration, for: .retrieveInitialColors)

        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>()

        let destination = ColorsListView.Destination(destinationType: .colorsList, destinationConfigurations: configs, navigationConfigurations: navigationConfigs, parentDestination: nil)
        destination.assignInteractor(interactor, to: .colors)

        return destination
    }
}

/// A step type used to tag and locate the group step in the group tests.
private enum GroupTestStep: ActionIdentifying {
    case retrieveGroup
}

/// Merges the results of a group of `.colors` retrievals into a single `.colors` value.
private struct ColorsGroupMerger: ActionResultsMerging {
    func merge(results: [ActionResult<AppContentType>]) throws -> AppContentType {
        let allColors = results.flatMap { result -> [ColorViewModel] in
            if case .colors(models: let models) = result.content {
                return models
            }
            return []
        }
        return .colors(models: allColors)
    }
}

/// The error returned by `FailingGroupAssistant`.
private struct GroupChildFailureError: Error {}

/// Returns a colors result immediately.
private struct ImmediateSuccessGroupAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        .success(.colors(models: [ColorViewModel(colorID: UUID(), color: .blue, name: "blue")]))
    }
}

/// Yields several times to simulate work, then returns a failure. The yields give the group's for-await loop time to record any already-completed sibling results before this failure is processed.
private struct FailingGroupAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        for _ in 0..<50 { await Task.yield() }
        return .failure(GroupChildFailureError())
    }
}

/// Coordinates execution order between a test and group children via two channels:
/// 1. a child to signal it has started
/// 2. the test to signal that it releases a waiting child
///
/// Usage:
///   - A child calls `signalStarted()` when it begins its work
///   - The test calls `waitUntilChildStarted()` to block all other children until the first child is active
///   - A different child calls `waitUntilOpened()` to pause before doing something
///   - The test calls `open()` to release the waiting child
private actor GateController {
    private var childStartedContinuation: CheckedContinuation<Void, Never>?
    private var openGateContinuation: CheckedContinuation<Void, Never>?

    // Latches remember a signal that arrives before its matching wait call has registered a
    // continuation, so a fast child (e.g. one that signals with no suspension beforehand) can't
    // race ahead of the test and produce a lost wakeup that hangs forever.
    private var hasChildStarted = false
    private var isOpened = false

    /// Called by a child task to announce it has started running
    func signalStarted() {
        if let continuation = childStartedContinuation {
            childStartedContinuation = nil
            continuation.resume()
        } else {
            hasChildStarted = true
        }
    }

    /// Called by the test to wait until a child calls `signalStarted()`
    func waitUntilChildStarted() async {
        if hasChildStarted { return }
        await withCheckedContinuation { continuation in
            self.childStartedContinuation = continuation
        }
    }

    /// Called by a child task to wait until the test calls `open()`
    func waitUntilOpened() async {
        if isOpened { return }
        await withCheckedContinuation { continuation in
            self.openGateContinuation = continuation
        }
    }

    /// Called by the test to release a child suspended in `waitUntilOpened()`
    func open() {
        if let continuation = openGateContinuation {
            openGateContinuation = nil
            continuation.resume()
        } else {
            isOpened = true
        }
    }
}

/// Signals the gate that it has produced its result, then returns success immediately. Pairing this with
/// a gated failing assistant guarantees this sibling's success is recorded before the failure is released,
/// since `withTaskGroup`'s `for await` gives no ordering guarantee between children that never suspend.
private struct GatedImmediateSuccessGroupAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest

    let interactorType: InteractorType = .colors
    let gate: GateController

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        await gate.signalStarted()
        return .success(.colors(models: [ColorViewModel(colorID: UUID(), color: .blue, name: "blue")]))
    }
}

/// Waits behind the gate before returning a failure, giving the test control over when the failure fires.
private struct GatedFailingGroupAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors
    let gate: GateController

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        await gate.waitUntilOpened()
        return .failure(GroupChildFailureError())
    }
}

/// Signals the gate when it starts, then checks for cancellation in a for loop.
private struct GatedSlowGroupAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors
    let gate: GateController

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        await gate.signalStarted()
        for _ in 0..<10_000 {
            if Task.isCancelled { break }
            await Task.yield()
        }
        return .success(.colors(models: []))
    }
}

/// Simulates a long-running operation by yielding in a loop while checking for cancellation.
/// Exits early when the parent task group is cancelled.
private struct SlowGroupAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        for _ in 0..<10_000 {
            if Task.isCancelled { break }
            await Task.yield()
        }
        return .success(.colors(models: []))
    }
}

/// A custom action that always succeeds without ever checking `Task.isCancelled`, unlike a plain
/// `Action`, which self-converts to `.failure` on post-success cancellation before ever returning to a
/// parent `ActionGroup`. Used to test whether `ActionGroup`'s own post-completion cancellation check is
/// reachable when every child reports success regardless of cancellation state.
@MainActor private final class UncancellableSuccessAction: ActionPerformable {
    typealias ContentType = AppContentType

    let id = UUID()
    var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    let identifier: (any ActionIdentifying)? = nil
    var actionType: (any InteractorRequestActionTypeable)? { nil }
    let shouldEndParentTaskOnFailure: Bool = false
    let shouldSaveResult: Bool = true

    let gate: GateController
    let colorModel: ColorViewModel

    init(gate: GateController, colorModel: ColorViewModel) {
        self.gate = gate
        self.colorModel = colorModel
    }

    func perform(with content: AppContentType?, sequenceOutputs: ActionCollectionResults<AppContentType>) async -> Result<ActionCollectionResults<AppContentType>, any Error> {
        await gate.signalStarted()
        await gate.waitUntilOpened()
        var outputs = sequenceOutputs
        outputs.add(ActionResult(identifier: identifier, origin: .none, result: .success(.colors(models: [colorModel]))))
        return .success(outputs)
    }
}

/// Builds an `UncancellableSuccessAction`, for use as an `ActionGroupConfiguration` child.
@MainActor private struct UncancellableSuccessActionConfig: ActionConfiguring {
    enum ActionType: InteractorRequestActionTypeable { case uncancellableSuccess }
    typealias InteractorType = ColorsListView.InteractorType
    typealias ContentType = AppContentType

    let actionType: ActionType = .uncancellableSuccess
    let assistant: InteractorAssistantType = .basicAsync
    var outputConduit: (any ActionSequenceConduiting<ContentType>)?
    let shouldEndParentTaskOnFailure: Bool = false
    let shouldSaveResult: Bool = true

    let gate: GateController
    let colorModel: ColorViewModel

    func buildAssistant() throws -> any AsyncInteractorAssisting<InteractorType, ContentType> {
        let template = DestinationsSupport.errorMessage(for: .unsupportedInteractorAssistantType(message: ""))
        throw DestinationsError.unsupportedInteractorAssistantType(message: String(format: template, "\(actionType)"))
    }

    func buildAction(resultHandler: any InteractorResultHandling<InteractorType, ContentType>) throws -> any ActionPerformable<ContentType> {
        UncancellableSuccessAction(gate: gate, colorModel: colorModel)
    }
}

// MARK: - Branch test helpers

/// Identifiers for branch steps and their constituent path actions, used to locate results and document intent.
private enum BranchTestStep: ActionIdentifying {
    case retrieveBranch
    case bluePath
    case redPath
    case postSkipStep
}

/// Returns a single blue color model named "blue-branch", used to verify that a specific branch path ran.
private struct BlueBranchAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        .success(.colors(models: [ColorViewModel(colorID: UUID(), color: .blue, name: "blue-branch")]))
    }
}

/// Returns a single red color model named "red-branch", used to verify that the otherwise fallback path ran.
private struct RedBranchAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        .success(.colors(models: [ColorViewModel(colorID: UUID(), color: .red, name: "red-branch")]))
    }
}

/// Returns whatever content it received unchanged, used to verify what content was forwarded into this step.
private struct EchoContentAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        .success(content ?? .colors(models: []))
    }
}

/// Identifiers for failure-recording tests.
private enum StepFailureIdentifier: ActionIdentifying {
    case failingStep
    case successStep
    case group
}

/// Always returns a failure, used to verify that failure results are recorded in ActionCollectionResults.
private struct FailingColorAssistant: AsyncInteractorAssisting, DestinationTypes {
    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {}

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        .failure(StepAssistantFailureError())
    }
}

/// The error returned by `FailingColorAssistant`.
private struct StepAssistantFailureError: Error {}

/// Converts any content to a fixed green color model named "green-transformed", used to verify that a branch transformer ran.
private struct GreenColorTransformer: ContentTransformable {
    typealias ContentType = AppContentType
    func transform(input: AppContentType) throws -> AppContentType {
        .colors(models: [ColorViewModel(colorID: UUID(), color: .green, name: "green-transformed")])
    }
}

/// The error thrown by `FailingTransformer`.
private struct FailingTransformerError: Error {}

/// Always throws when transforming, used to verify that conduit transformer failures return `.failed`.
private struct FailingTransformer: ContentTransformable {
    typealias ContentType = AppContentType
    func transform(input: AppContentType) throws -> AppContentType {
        throw FailingTransformerError()
    }
}

/// The error thrown by `FailingMerger`.
private struct FailingMergerError: Error {}

/// Always throws when merging, used to verify that group merger failures return `.failed`.
private struct FailingMerger: ActionResultsMerging {
    func merge(results: [ActionResult<AppContentType>]) throws -> AppContentType {
        throw FailingMergerError()
    }
}
