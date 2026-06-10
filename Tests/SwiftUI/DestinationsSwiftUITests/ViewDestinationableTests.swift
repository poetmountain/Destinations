//
//  ViewDestinationableTests.swift
///
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class ViewDestinationableTests: XCTestCase, DestinationTypes {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
    }
    
    func test_assignInteractor() {
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        let colorsListConfigs = AppDestinationConfigurations<ColorsListView.EventType, DestinationType, ContentType, TabType>(configurations: [.color(model: nil): colorSelection])
        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>(configurations: [:])

        let destination = ColorsListView.Destination(destinationType: .colorsList, destinationConfigurations: colorsListConfigs, navigationConfigurations: navigationConfigs, parentDestination: nil)
        let state = ColorsListState(destination: destination)
        destination.stateModel = state
        let listView = ColorsListView(destination: destination, state: state)
        destination.assignAssociatedView(view: listView)

        let datasource = ColorsDatasource()
        destination.assignInteractor(interactor: datasource, for: .colors)
        
        XCTAssertNotNil(listView.destination().internalState.interactors[ColorsListView.InteractorType.colors])

    }

}
