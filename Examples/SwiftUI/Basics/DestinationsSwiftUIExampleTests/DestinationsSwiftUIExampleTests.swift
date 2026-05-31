//
//  DestinationsSwiftUIExampleTests.swift
//  DestinationsSwiftUIExampleTests
//
//  Created by Brett Walker on 10/29/24.
//

import XCTest
@testable import DestinationsSwiftUIExample

final class DestinationsSwiftUIExampleTests: XCTestCase {

    // Verifies that destination.stateModel and view.destinationState.stateModel
    // refer to the same object instance. Since they are different existential types
    // (any StateModeling<ColorsListDestination> vs any ColorsListStateModeling),
    // identity is confirmed by comparing their UUIDs via Identifiable.id.
    @MainActor
    func testStateModelIdentity() throws {
        let state = ColorsListState()
        let destination = ColorsListDestination(
            destinationConfigurations: nil,
            navigationConfigurations: nil,
            parentDestination: nil,
            state: state
        )
        let listView = ColorsListView(destination: destination, state: state)

        XCTAssertEqual(destination.stateModel?.id, listView.destinationState.stateModel.id)
    }

}
