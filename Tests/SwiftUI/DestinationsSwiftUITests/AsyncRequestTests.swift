//
//  AsyncRequestTests.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class AsyncRequestTests: XCTestCase, DestinationTypes {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
        continueAfterFailure = false
    }

    // MARK: - Destinationable.performAction(for:content:) async

    func test_performAction_async_returns_success_when_assistant_implements_asyncRequest() async throws {
        let destination = try await buildColorsDestination(assistant: TestAsyncColorsInteractorAssistant())

        let result = await destination.performAction(for: .retrieveInitialColors)

        switch result {
            case .success(let content):
                if case .colors(models: let models) = content {
                    XCTAssertEqual(models.count, 3, "Expected three colors from the datasource, got \(models.count)")
                } else {
                    XCTFail("Expected .colors content, got \(content)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_performAction_async_returns_missingInterfaceAction_when_no_action_registered() async {
        let destination = ColorsListView.Destination(destinationType: .colorsList)

        let result = await destination.performAction(for: .retrieveInitialColors)

        switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                if case DestinationsError.missingInterfaceAction = error {
                    // success
                } else {
                    XCTFail("Expected missingInterfaceAction failure, got \(error)")
                }
        }
    }

    func test_performAction_async_returns_incompatibleType_when_assistant_does_not_implement_asyncRequest() async throws {
        // ColorsInteractorAssistant only implements `handleAsyncRequest`. The default
        // implementation of `asyncRequest` returns an `incompatibleType` failure, which
        // is what we expect here.
        let destination = try await buildColorsDestination(assistant: ColorsInteractorAssistant())

        let result = await destination.performAction(for: .retrieveInitialColors)

        switch result {
            case .success:
                XCTFail("Expected failure because ColorsInteractorAssistant does not implement asyncRequest")
            case .failure(let error):
                if case DestinationsError.incompatibleType = error {
                    // success — the default extension returned the expected failure
                } else {
                    XCTFail("Expected incompatibleType failure, got \(error)")
                }
        }
    }

    func test_performAction_async_returns_interactorNotFound_when_eventType_has_no_configuration() async {
        // Construct a destination with an interface action wired up for an event type
        // that has neither a presentation configuration nor an interactor configuration.
        let configs = AppDestinationConfigurations<ColorsListView.EventType, DestinationType, ContentType, TabType>()
        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>()
        let destination = ColorsListView.Destination(destinationType: .colorsList, destinationConfigurations: configs, navigationConfigurations: navigationConfigs, parentDestination: nil)

        let interfaceAction = InterfaceAction<ColorsListView.EventType, DestinationType, ContentType>(function: { _, _ in })
        var action = interfaceAction
        action.eventType = .retrieveInitialColors
        try? destination.addInterfaceAction(action: action)

        let result = await destination.performAction(for: .retrieveInitialColors)

        switch result {
            case .success:
                XCTFail("Expected failure when no configuration exists for the event type")
            case .failure(let error):
                if case DestinationsError.interactorNotFound = error {
                    // success
                } else {
                    XCTFail("Expected interactorNotFound failure, got \(error)")
                }
        }
    }

    // MARK: - AsyncInteractorAssisting.asyncRequest

    func test_asyncRequest_returns_success_when_assistant_implements_it() async throws {
        let destination = try await buildColorsDestination(assistant: TestAsyncColorsInteractorAssistant())
        let assistant = TestAsyncColorsInteractorAssistant()

        let result = await assistant.asyncRequest(destination: destination, actionType: ColorsRequest.ActionType.retrieve, content: nil)

        switch result {
            case .success(let content):
                if case .colors(models: let models) = content {
                    XCTAssertEqual(models.count, 3, "Expected three colors from the datasource, got \(models.count)")
                } else {
                    XCTFail("Expected .colors content, got \(content)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    func test_asyncRequest_default_implementation_returns_incompatibleType_failure() async throws {
        // ColorsInteractorAssistant does not override `asyncRequest`, so calling it
        // should hit the default extension which returns `.incompatibleType`.
        let destination = try await buildColorsDestination(assistant: ColorsInteractorAssistant())
        let assistant = ColorsInteractorAssistant()

        let result = await assistant.asyncRequest(destination: destination, actionType: ColorsRequest.ActionType.retrieve, content: nil)

        switch result {
            case .success:
                XCTFail("Expected failure from default asyncRequest implementation")
            case .failure(let error):
                if case DestinationsError.incompatibleType = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Expected incompatibleType failure, got \(error)")
                }
        }
    }

    func test_asyncRequestForAction_with_mismatched_action_type_returns_incompatibleType_failure() async throws {
        let destination = try await buildColorsDestination(assistant: TestAsyncColorsInteractorAssistant())
        let assistant = TestAsyncColorsInteractorAssistant()

        // Pass an action type that doesn't match the assistant's Request.ActionType (ColorsRequest.ActionType).
        let mismatchedAction: any InteractorRequestActionTypeable = TestInteractorOptions.ActionType.increaseCount

        let result = await assistant.asyncRequestForAction(destination: destination, actionType: mismatchedAction, content: nil, resultTransformer: nil)

        switch result {
            case .success:
                XCTFail("Expected failure when actionType cannot be cast to Request.ActionType")
            case .failure(let error):
                if case DestinationsError.incompatibleType = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Expected incompatibleType failure, got \(error)")
                }
        }
    }

    func test_asyncRequestForAction_via_actionType_existential_returns_success() async throws {
        // Exercises the `AsyncInteractorAssisting` extension overload that takes
        // `actionType: any InteractorRequestActionTypeable` and casts to the assistant's
        // associated `Request.ActionType` before forwarding to the typed `asyncRequest`.
        let destination = try await buildColorsDestination(assistant: TestAsyncColorsInteractorAssistant())
        let assistant = TestAsyncColorsInteractorAssistant()

        let actionType: any InteractorRequestActionTypeable = ColorsRequest.ActionType.retrieve

        let result = await assistant.asyncRequestForAction(destination: destination, actionType: actionType, content: nil, resultTransformer: nil)

        switch result {
            case .success(let content):
                if case .colors = content {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Expected .colors content, got \(content)")
                }
            case .failure(let error):
                XCTFail("Expected success result, got failure: \(error)")
        }
    }

    // MARK: - Helpers

    /// Builds a `ColorsListView.Destination` wired up manually (without going through `ViewFlow`),
    /// so tests have full control over what's registered and so the destination's `prepareForPresentation`
    /// lifecycle is not triggered. The supplied async assistant is registered for the `.retrieveInitialColors`
    /// event type.
    private func buildColorsDestination(assistant: some AsyncInteractorAssisting<ColorsListView.InteractorType, ContentType>) async throws -> ColorsListView.Destination {
        let configs = AppDestinationConfigurations<ColorsListView.EventType, DestinationType, ContentType, TabType>()
        let interactorConfig = InteractorConfiguration<ColorsListView.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .basic)
        configs.addInteractorConfiguration(configuration: interactorConfig, for: .retrieveInitialColors)

        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>()

        let destination = ColorsListView.Destination(destinationType: .colorsList, destinationConfigurations: configs, navigationConfigurations: navigationConfigs, parentDestination: nil)

        let datasource = ColorsDatasource()
        destination.assignInteractor(datasource, to: .colors)
        destination.assignInteractorAssistant(assistant: assistant, for: .retrieveInitialColors)

        // Build the interactor interface actions so that the async `performAction` finds the
        // expected `interfaceActions[.retrieveInitialColors]` entry. The closure body is
        // unused for the interactor path, but the entry itself must exist.
        destination.buildInteractorActions { _ in }

        return destination
    }
}
