//
//  NavigatingControllerDestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class NavigatingControllerDestinationableTests: XCTestCase, DestinationTypes {
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    override func tearDown() async throws {
        sceneDelegate?.navigationController.setViewControllers([], animated: false)
        sceneDelegate?.navigationController = UINavigationController()
        sceneDelegate?.window?.rootViewController = sceneDelegate?.createRootViewController()

    }

    func test_addChild() {

        let navDestination = NavigationControllerDestination<StartViewController, StartViewController.UserInteractions, StartViewController.DestinationType, StartViewController.ContentType, StartViewController.TabType, StartViewController.InteractorType>(destinationType: .start)
        
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        navDestination.addChild(childDestination: colors)
        
        XCTAssertEqual(colors.parentDestinationID(), navDestination.id)
        XCTAssert(navDestination.childDestinations().contains(where: { $0.id == colors.id}))
        XCTAssertEqual(navDestination.currentChildDestination()?.id, colors.id)
    }

    func test_navigateBackInStack() {
        let navDestination = NavigationControllerDestination<StartViewController, StartViewController.UserInteractions, StartViewController.DestinationType, StartViewController.ContentType, StartViewController.TabType, StartViewController.InteractorType>(destinationType: .start)
        let navController = StartViewController(destination: navDestination)
        navDestination.assignAssociatedController(controller: navController)
        
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        navDestination.addChild(childDestination: colors)
        
        let detail = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let detailController = ColorDetailViewController(destination: detail)
        detail.assignAssociatedController(controller: detailController)
        navDestination.addChild(childDestination: detail)
        
        XCTAssertEqual(navDestination.childDestinations().count, 2)
        
        navDestination.navigateBackInStack()
        
        XCTAssertEqual(navDestination.childDestinations().count, 1, "Expected child destinations to be 1, but found \(navDestination.childDestinations().count)")
        XCTAssertEqual(navDestination.currentChildDestination()?.id, colors.id)
        
    }
}
