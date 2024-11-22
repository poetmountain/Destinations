//
//  SplitViewControllerDestinationableTests.swift
//  DestinationsUIKitTests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class SplitViewControllerDestinationableTests: XCTestCase, DestinationTypes {

    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .verbose
    }

    override func tearDown() async throws {
        sceneDelegate?.navigationController.setViewControllers([], animated: false)
        sceneDelegate?.navigationController = UINavigationController()
        sceneDelegate?.window?.rootViewController = sceneDelegate?.createRootViewController()
    }

    func test_column_for_destinationID() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: .splitView, destinationsForColumns: [.primary: colors, .secondary: home])
        
        let colorsColumn = splitViewDestination.column(destinationID: colors.id)
        XCTAssertEqual(colorsColumn, .primary)
        
        let homeColumn = splitViewDestination.column(destinationID: home.id)
        XCTAssertEqual(homeColumn, .secondary)
        
    }

    
    func test_replaceChild() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ControllerDestination<HomeUserInteractions, HomeViewController, PresentationConfiguration, InteractorType>(destinationType: .home, destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = HomeViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: .splitView, destinationsForColumns: [.primary: colors, .secondary: home])
        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        splitViewDestination.updateChildren()
                
        let newDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)

        splitViewDestination.replaceChild(currentID: home.id, with: newDestination)
        
        // new Destination should be a child
        XCTAssertTrue(splitViewDestination.childDestinations.contains(where: { $0.id == newDestination.id }), "Expected new Destination to be in the childDestinations array")
        
        // home Destination should not be a child
        XCTAssertFalse(splitViewDestination.childDestinations.contains(where: { $0.id == home.id }), "Expected the old Destination to be removed from childDestinations")
        
        // new Destination should be the new current
        XCTAssertEqual(splitViewDestination.currentChildDestination?.id, newDestination.id, "Expected new Destination to be the current child, but found \(String(describing: splitViewDestination.currentChildDestination?.id))")

        // currentDestination should find the current Destination
        let current = splitViewDestination.currentDestination(for: .secondary)
        XCTAssertEqual(current?.id, newDestination.id, "Expected the child Destination to be colorDetail, but the current is \(String(describing: current?.type))")
    
        
    }
    
    func test_presentDestination() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: .splitView, destinationsForColumns: [.primary: colors, .secondary: home])
        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        splitViewDestination.updateChildren()
        
        let newDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)
        splitViewDestination.presentDestination(destination: newDestination, in: .secondary)
        
        XCTAssertEqual(newDestination.parentDestinationID, splitViewDestination.id)
        XCTAssertTrue(splitViewDestination.childDestinations.contains { $0.id == newDestination.id })

        let thirdDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let thirdController = ColorDetailViewController(destination: thirdDestination)
        thirdDestination.assignAssociatedController(controller: thirdController)
        splitViewDestination.presentDestination(destination: thirdDestination, in: .secondary)
        
        XCTAssertEqual(thirdDestination.parentDestinationID, splitViewDestination.id)
        XCTAssertTrue(splitViewDestination.childDestinations.contains { $0.id == thirdDestination.id })

        // primary column + home column + 2 presentations = 4
        XCTAssertEqual(splitViewDestination.childDestinations.count, 4)
        
        // navigation controller in the home column should have 3 children
        let homeColumnController = splitViewController.viewController(for: .secondary)
        XCTAssertEqual(homeColumnController?.navigationController?.children.count, 3)
    }
    
    
    func test_currentDestination() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: .splitView, destinationsForColumns: [.primary: colors, .secondary: home])
        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        splitViewDestination.updateChildren()
        
        let newDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)
        splitViewDestination.presentDestination(destination: newDestination, in: .secondary)
        
        let childDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let childController = ColorDetailViewController(destination: childDestination)
        childDestination.assignAssociatedController(controller: childController)
        splitViewDestination.presentDestination(destination: childDestination, in: .secondary)
    
        let current = splitViewDestination.currentDestination(for: .secondary)
        
        // currentDestination should find the current Destination
        XCTAssertEqual(current?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")
        
        XCTAssertEqual(splitViewDestination.currentChildDestination?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: splitViewDestination.currentChildDestination?.type))")
        
    }
    
    func test_rootDestination() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: .splitView, destinationsForColumns: [.primary: colors, .secondary: home])
        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        splitViewDestination.updateChildren()
        
        let newDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)
        splitViewDestination.presentDestination(destination: newDestination, in: .secondary)
        
        let childDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let childController = ColorDetailViewController(destination: childDestination)
        childDestination.assignAssociatedController(controller: childController)
        splitViewDestination.presentDestination(destination: childDestination, in: .secondary)
    
        let root = splitViewDestination.rootDestination(for: .secondary)
        
        XCTAssertEqual(root?.id, home.id, "Expected the child Destination to be the current one, but the current is \(String(describing: root?.type))")
        
    }
    
    func test_updateColumnControllers() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: .splitView, destinationsForColumns: [.primary: colors, .secondary: home])
        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        splitViewDestination.updateChildren()
        
        let newDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)
        
        let childDestination = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let childController = ColorDetailViewController(destination: childDestination)
        childDestination.assignAssociatedController(controller: childController)

        splitViewDestination.updateColumnControllers(columns: [.primary: newDestination.id, .secondary: childDestination.id])
        
        XCTAssertEqual(splitViewDestination.destinationIDsForColumns[.primary], newDestination.id)
        XCTAssertEqual(splitViewDestination.destinationIDsForColumns[.secondary], childDestination.id)

    }
}
