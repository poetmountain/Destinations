//
//  TabBarControllerDestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class TabBarControllerDestinationableTests: XCTestCase, DestinationTypes {
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
    }

    override func tearDown() async throws {
        sceneDelegate?.navigationController.setViewControllers([], animated: false)
        sceneDelegate?.navigationController = UINavigationController()
        sceneDelegate?.window?.rootViewController = sceneDelegate?.createRootViewController()

    }

    func test_tab_for_destinationID() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, EventType, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        tabsDestination?.updateChildren()
        
        let tab = tabsDestination?.tab(destinationID: colors.id)
        
        XCTAssertEqual(tab, TabType.palettes)
    }
    
    func test_tab_for_type() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, EventType, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        tabsDestination?.updateChildren()
        
        let tab = tabsDestination?.tab(for: .palettes)
        
        XCTAssertEqual(tab?.type, TabType.palettes)
    }

    func test_tabIndex_for_type() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)

        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, EventType, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        tabsDestination?.updateChildren()
        
        let tabIndex = tabsDestination?.tabIndex(for: .home)
        
        XCTAssertEqual(tabIndex, 1)

    }
    
    func test_tab_containing_controller() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, AppTabBarController.Events, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        let tab = tabsDestination?.tab(containing: colorsController)
        
        XCTAssertEqual(tab, TabType.palettes)
    }
    
    func test_currentDestination_for_tab() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, AppTabBarController.Events, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        let newDestination = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)
        try? tabsDestination?.presentDestination(destination: newDestination, in: .palettes)
        
        let destination = tabsDestination?.currentDestination(for: .palettes)
        
        XCTAssertEqual(destination?.id, newDestination.id, "Expected current destination to be newDestination, but found \(String(describing: destination?.type))")
    }
    
    func test_updateSelectedTab() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, AppTabBarController.Events, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        tabsDestination?.updateChildren()
        
        try? tabsDestination?.updateSelectedTab(type: .home)
        
        XCTAssertEqual(tabsDestination?.selectedTab.type, TabType.home)
    }
    
    func test_replaceChild() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, AppTabBarController.Events, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .home)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        tabsDestination?.updateCurrentDestination(destinationID: home.id)
        
        let newDestination = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)

        tabsDestination?.replaceChild(currentID: home.id, with: newDestination)
        
        if let tabsDestination = try? XCTUnwrap(tabsDestination) {
            XCTAssertTrue(tabsDestination.childDestinations().contains(where: { $0.id == newDestination.id }), "Expected new Destination to be in the childDestinations array")
            XCTAssertFalse(tabsDestination.childDestinations().contains(where: { $0.id == home.id }), "Expected the old Destination to be removed from childDestinations")
            XCTAssertEqual(tabsDestination.currentChildDestination()?.id, newDestination.id, "Expected new Destination to be the current child, but found \(String(describing: tabsDestination.currentChildDestination()?.id))")
            
            let homeTabController = tabsDestination.currentDestination(for: .home)
            XCTAssertTrue(homeTabController?.id == newController.destination().id, "Expected Home nav controllers to be ColorDetailViewController, but instead the array is \(String(describing: homeTabController))")
        }
        
    }
    
    func test_presentDestination() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, AppTabBarController.Events, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        let newDestination = ColorDetailViewController.Destination(destinationType: .colorDetail)
        let newController = ColorDetailViewController(destination: newDestination)
        newDestination.assignAssociatedController(controller: newController)
        
        try? tabsDestination?.presentDestination(destination: newDestination, in: .home)
        
        if let tabsDestination = try? XCTUnwrap(tabsDestination) {
            XCTAssert(tabsDestination.childDestinations().contains(where: { $0.id == newDestination.id }))
            XCTAssertEqual(newDestination.parentDestinationID(), tabsDestination.id)
            // When presenting a tab in a different tab, that tab should become the active tab. In this test the original selected tab was ".palettes"
            XCTAssertEqual(tabsDestination.selectedTab.type, .home)
        }
    }
    
    func test_currentDestination_for_non_group_destination() {

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
            //PresentationConfiguration(destinationType: .colorsList, presentationType: .tabBar(tab: .palettes), assistantType: .basic),

        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController, startingTabs: startingTabs)
        appFlow.start()
        
        wait(timeout: 0.3)
                
        if let lastDestination = appFlow.activeDestinations.last as? any ControllerDestinationable, let tabBar = appFlow.findTabBarInViewHierarchy(currentDestination: lastDestination) {
            
            let homeDestination = tabBar.currentDestination(for: .home)
            XCTAssertNotNil(homeDestination)
            XCTAssertEqual(homeDestination?.type, .home)
            
        } else {
            XCTFail("Couldn't find tab bar")
        }
    }
    
    
    
    func test_currentDestination_for_group_destination() {

        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let testDestinations = TestDestinations()

        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")

        let startingTabs: [AppTabType] = [.home, .palettes]
        let tabsType: RouteDestinationType = .tabBar(tabs: startingTabs)
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: tabsType, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorsList, presentationType: .tabBar(tab: .palettes), assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController, startingTabs: startingTabs)
        appFlow.start()

        wait(timeout: 0.3)
        
        if let lastDestination = appFlow.activeDestinations.last as? any ControllerDestinationable & DestinationTypeable, let tabBar = appFlow.findTabBarInViewHierarchy(currentDestination: lastDestination) {
            
            let listID = tabBar.currentDestination(for: .palettes)?.id
            
            let detailPresentation = PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), assistantType: .basic)
            let detailDestination = appFlow.presentDestination(configuration: detailPresentation)
            
            wait(timeout: 0.3)
            
            let detail = try! XCTUnwrap(detailDestination)
            XCTAssertEqual(detail.type, .colorDetail)

            let current = tabBar.currentDestination(for: .palettes)
            XCTAssertEqual(current?.id, detail.id, "Expected to find Detail destination, but found \(String(describing: appFlow.destination(for: current!.id)?.description))")
            
            
            if let listID, let listDestination = appFlow.destination(for: listID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                XCTAssertEqual(listDestination.type, .colorsList)
                
                detailDestination?.moveBackInNavigationStack()
                      
                wait(timeout: 0.5)

                XCTAssertEqual(tabBar.currentDestination(for: .palettes)?.id, listID, "Expected to find ColorsList destination, but found \(String(describing: tabBar.currentChildDestination()?.description))")
                
            } else {
                XCTFail("Could not find list Destination")
            }
            
            
        } else {
            XCTFail("Couldn't find tab bar")
        }
    }
    
    
    func test_updateTabControllers() {
        let colors = TestColorsViewController.Destination(destinationType: .colorsList, destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailViewController.Destination(destinationType: .colorDetail)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController, AppTabBarController.Events, DestinationType, ContentType, TabType, InteractorType>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        tabsDestination?.updateChildren()
        
        let newDestination = ColorDetailViewController.Destination(destinationType: .colorDetail)

        tabsDestination?.updateTabControllers(destinations: [colors, newDestination], for: [TabModel(type: TabType.palettes), TabModel(type: TabType.home)])
        
        XCTAssertEqual(tabsDestination?.destinationIDsForTabs[.home], newDestination.id)

    }
    
}
