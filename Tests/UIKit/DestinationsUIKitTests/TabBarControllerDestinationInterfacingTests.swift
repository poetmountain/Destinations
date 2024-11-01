//
//  TabBarControllerDestinationInterfacingTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class TabBarControllerDestinationInterfacingTests: XCTestCase, DestinationTypes {


    func test_tabIndex_for_tab() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)

        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController.PresentationConfiguration, AppTabBarController>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        let tabIndex = tabsController.tabIndex(for: .home)
        
        XCTAssertEqual(tabIndex, 1)
        
    }

    func test_tab_for_destinationID() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)

        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController.PresentationConfiguration, AppTabBarController>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        let tab = tabsController.tab(destinationID: home.id)
        
        XCTAssertEqual(tab, TabType.home)
    }
    
    func test_gotoTab() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController.PresentationConfiguration, AppTabBarController>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        
        try? tabsController.gotoTab(.home)
        
        XCTAssertEqual(tabsDestination?.selectedTab.type, TabType.home)
    }
    
    func test_currentController_for_tab() {
        let colors = TestColorsDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let colorsController = TestColorsViewController(destination: colors)
        colors.assignAssociatedController(controller: colorsController)
        let home = ColorDetailDestination(destinationConfigurations: nil, navigationConfigurations: nil)
        let homeController = ColorDetailViewController(destination: home)
        home.assignAssociatedController(controller: homeController)
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let tabsDestination = TabBarControllerDestination<AppTabBarController.PresentationConfiguration, AppTabBarController>(type: .tabBar(tabs: startingTabs), tabDestinations: [colors, home], tabTypes: startingTabs, selectedTab: .palettes)
        let tabsController = AppTabBarController(destination: tabsDestination!)
        tabsDestination?.assignAssociatedController(controller: tabsController)
        tabsDestination?.updateChildren()
        
        let palettesController = tabsController.currentController(for: .palettes)
        XCTAssertEqual(palettesController?.destination().id, colors.id)
    }
}
