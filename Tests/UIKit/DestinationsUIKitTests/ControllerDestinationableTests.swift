//
//  ControllerDestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class ControllerDestinationableTests: XCTestCase, DestinationTypes {

    
    func test_assignInteractor() {
        let colorSelection = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        let colorsListConfigs = AppDestinationConfigurations<TestColorsDestination.UserInteractions, DestinationType, AppContentType, TabType>(configurations: [.color(model: nil): colorSelection])
        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, AppContentType, TabType>(configurations: [:])

        let destination = TestColorsDestination(destinationConfigurations: colorsListConfigs, navigationConfigurations: navigationConfigs, parentDestination: nil)

        
        let datasource = TestColorsDatasource(with: ColorsPresenter())
        destination.assignInteractor(interactor: datasource, for: .colors)
        
        XCTAssertNotNil(destination.internalState.interactors[.colors])
    }

}
