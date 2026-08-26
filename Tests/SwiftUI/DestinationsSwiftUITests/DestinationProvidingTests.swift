//
//  DestinationProvidingTests.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import SwiftUI

@testable import DestinationsSwiftUI
import Destinations

@MainActor final class DestinationProvidingTests: XCTestCase {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
        continueAfterFailure = false
    }

    // MARK: - Baseline

    func test_preflight_returnsNil_whenAllEventsAreRegistered() {
        let provider = ColorsListProvider()
        XCTAssertNil(provider.presentationsPreflight())
    }

    func test_preflightIgnoredEvents_defaultsToEmpty() {
        let provider = ColorsListProvider()
        XCTAssertTrue(provider.preflightIgnoredEvents.isEmpty)
    }

    // MARK: - preflightIgnoredEvents

    func test_preflight_returnsMissingEvent_whenEventHasNoRegistration() {
        let provider = TestPreflightProvider()
        XCTAssertEqual(provider.presentationsPreflight(), .retrieveInitialColors)
    }

    func test_preflight_returnsNil_whenMissingEventIsIgnored() {
        let provider = TestPreflightProvider(ignoring: [.retrieveInitialColors])
        XCTAssertNil(provider.presentationsPreflight())
    }

    func test_preflight_returnsNil_whenAllMissingEventsAreIgnored() {
        var provider = TestPreflightProvider()
        provider.presentationsData = [:]
        provider.preflightIgnoredEvents = ColorsListInterfaceState.Events.allCases
        XCTAssertNil(provider.presentationsPreflight())
    }

    func test_preflightIgnoredEvents_canBeSet() {
        var provider = TestPreflightProvider()
        XCTAssertTrue(provider.preflightIgnoredEvents.isEmpty)
        provider.preflightIgnoredEvents = [.retrieveInitialColors]
        XCTAssertEqual(provider.preflightIgnoredEvents, [.retrieveInitialColors])
    }

    func test_preflight_returnsNil_whenIgnoredEventIsAlsoRegistered() {
        // Ignoring an already-registered event should have no negative effect.
        let provider = TestPreflightProvider(ignoring: [.color(model: nil), .retrieveInitialColors])
        XCTAssertNil(provider.presentationsPreflight())
    }
}

// A minimal provider that intentionally leaves `.retrieveInitialColors` unregistered,
// so tests can exercise preflight ignore-list behavior against a real missing event.
private struct TestPreflightProvider: ViewDestinationProviding, DestinationTypes {

    typealias Destination = ColorsListView.Destination
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    var interactorsData: [Destination.EventType: any InteractorConfiguring<Destination.InteractorType>] = [:]
    var preflightIgnoredEvents: [Destination.EventType] = []

    init(ignoring events: [Destination.EventType] = []) {
        let colorSelection = PresentationConfiguration(
            destinationType: .colorDetail,
            presentationType: .navigationStack(type: .present),
            assistantType: .basic
        )
        presentationsData = [.color(model: nil): colorSelection]
        preflightIgnoredEvents = events
    }

    func buildDestination(
        destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?,
        navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?,
        configuration: DestinationPresentation<DestinationType, ContentType, TabType>,
        appFlow: some ViewFlowable<DestinationType, ContentType, TabType>
    ) -> Destination? {
        nil
    }
}
