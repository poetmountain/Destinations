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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_assignInteractor() {
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        let colorsListConfigs = AppDestinationConfigurations<ColorsListDestination.UserInteractions, PresentationConfiguration>(configurations: [.color(model: nil): colorSelection])
        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, PresentationConfiguration>(configurations: [:])

        let destination = ColorsListDestination(destinationConfigurations: colorsListConfigs, navigationConfigurations: navigationConfigs, parentDestination: nil)
        let listView = ColorsListView(destination: destination)
        destination.assignAssociatedView(view: listView)
        
        let datasource = ColorsDatasource(with: ColorsPresenter())
        destination.assignInteractor(interactor: datasource, for: .colors)
        
        XCTAssertNotNil(listView.destination().internalState.interactors[ColorsListDestination.InteractorType.colors])

    }

}
