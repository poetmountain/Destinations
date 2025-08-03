//
//  ControllerFlowableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class ControllerFlowableTests: XCTestCase, DestinationTypes {
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    override func tearDown() async throws {
        sceneDelegate?.navigationController.setViewControllers([], animated: false)
        sceneDelegate?.navigationController = UINavigationController()
        sceneDelegate?.window?.rootViewController = sceneDelegate?.createRootViewController()

    }

    func test_findNavigatorInViewHierarchy() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let testDestinations = TestDestinations()
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsType: RouteDestinationType = .tabBar(tabs: startingTabs)

        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: tabsType, presentationType: .addToCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController, startingTabs: startingTabs)
        appFlow.start()

        if let lastDestination = appFlow.activeDestinations.last as? any ControllerDestinationable & DestinationTypeable {
            let navigator = appFlow.findNearestNavigatorInViewHierarchy(currentDestination: lastDestination)
    
            XCTAssertNotNil(navigator, "Could not find navigator")
        } else {
            XCTFail("No last destination found")
        }
    }

    
    func test_findTabBarInViewHierarchy() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let testDestinations = TestDestinations()

        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")

        let startingTabs: [AppTabType] = [.home, .palettes]
        let tabsType: RouteDestinationType = .tabBar(tabs: startingTabs)
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: tabsType, presentationType: .addToCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .home), assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController, startingTabs: startingTabs)
        appFlow.start()

        if let lastDestination = appFlow.activeDestinations.last as? any ControllerDestinationable & DestinationTypeable {
            let tabBar = appFlow.findTabBarInViewHierarchy(currentDestination: lastDestination)
            XCTAssertNotNil(tabBar, "Could not find tab bar")
        } else {
            XCTFail("No last destination found")
        }
    }
    
    func test_replaceRoot() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let testDestinations = TestDestinations()

        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")

        let startingTabs: [AppTabType] = [.home, .palettes]
        let tabsType: RouteDestinationType = .tabBar(tabs: startingTabs)
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: tabsType, presentationType: .addToCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .home), assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController, startingTabs: startingTabs)
        appFlow.start()
                
        let newDestination = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceRoot, assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination {
            XCTAssertEqual(currentDestination.type, .colorDetail)
            XCTAssertEqual(appFlow.rootDestination?.type, .colorDetail)
            XCTAssertEqual(appFlow.activeDestinations.count, 1)
        } else {
            XCTFail("Expected destination to be .colorDetail, got \(type(of: appFlow.currentDestination))")
        }
    }
    
    
    func test_replaceCurrent_with_one_destination() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let testDestinations = TestDestinations()

        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")

        let startingDestination = PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController)
        appFlow.start()
                
        let newDestination = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination {
            XCTAssertEqual(currentDestination.type, .colorDetail)
            XCTAssertEqual(appFlow.rootDestination?.type, .colorDetail)
            XCTAssertEqual(appFlow.activeDestinations.count, 1)
        } else {
            XCTFail("Expected destination to be .colorDetail, got \(type(of: appFlow.currentDestination))")
        }
    }
}
