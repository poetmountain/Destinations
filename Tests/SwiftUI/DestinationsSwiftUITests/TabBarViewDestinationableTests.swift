//
//  TabBarViewDestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class TabBarViewDestinationableTests: XCTestCase, DestinationTypes {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .verbose
    }

    func test_tab_for_destinationID() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        let tab = tabsDestination?.tab(destinationID: homeDestination.id)
        
        XCTAssertEqual(tab, TestTabType.home)
    }
    
    func test_tab_for_type() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        let tab = tabsDestination?.tab(for: .home)
        
        XCTAssertEqual(tab?.type, TestTabType.home)
    }
    
    func test_tabIndex_for_type() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        let tabIndex = tabsDestination?.tabIndex(for: .home)
        
        XCTAssertEqual(tabIndex, 0)
    }
    
    func test_updateSelectedTab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()

        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        try? tabsDestination?.updateSelectedTab(type: .group)
        
        XCTAssertEqual(tabsDestination?.selectedTab.type, TestTabType.group)
    }
    
    func test_updateSelectedTab_preserve_current_destination_in_nav_stack() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navigationStackDestination = TestNavigatorDestination<TestGroupView>()
        let navView = TestGroupView(destination: navigationStackDestination)
        navigationStackDestination.assignAssociatedView(view: navView)
        let childDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        if let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, navigationStackDestination], tabTypes: [.home, .group], selectedTab: .home) {
            
            try? tabsDestination.presentDestination(destination: childDestination, in: .group)
            
            try? tabsDestination.updateSelectedTab(type: .home)
            
            XCTAssertEqual(tabsDestination.selectedTab.type, TestTabType.home)
            
            try? tabsDestination.updateSelectedTab(type: .group)

            XCTAssertEqual(tabsDestination.selectedTab.type, TestTabType.group)

            // currentChildDestination should be the current Destination
            XCTAssertEqual(tabsDestination.currentChildDestination()?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination.currentChildDestination()?.type))")
            
        } else {
            XCTFail("TabViewDestination was not created")

        }
    }
    
    func test_replaceChild() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let presentedDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        if let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home) {
            
            tabsDestination.replaceChild(currentID: homeDestination.id, with: presentedDestination)
            
            // new Destination should be a child
            XCTAssertTrue(tabsDestination.childDestinations().contains { $0.id == presentedDestination.id })
            
            // home Destination should not be a child
            XCTAssertFalse(tabsDestination.childDestinations().contains { $0.id == homeDestination.id })

            // new Destination should be the new current
            XCTAssertEqual(tabsDestination.currentChildDestination()?.id, presentedDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination.currentChildDestination()?.type))")
            
            // currentDestination should find the current Destination
            let current = tabsDestination.currentDestination(for: .home)
            XCTAssertEqual(current?.id, presentedDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")
            
        } else {
            XCTFail("TabViewDestination was not created")
        }
    }
    
    func test_presentDestination_in_single_view_tab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let presentedDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.replacement)
        
        if let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home) {
            
            try? tabsDestination.presentDestination(destination: presentedDestination, in: .home)
            
            XCTAssertTrue(tabsDestination.childDestinations().contains { $0.id == presentedDestination.id })

            // currentDestination should find the current Destination
            let current = tabsDestination.currentDestination(for: .home)
            XCTAssertEqual(current?.id, presentedDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")
            
            XCTAssertEqual(tabsDestination.selectedTab.type, TestTabType.home)

        } else {
            XCTFail("TabViewDestination was not created")
        }
    }
    
    func test_presentDestination_in_navigationStack_tab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navigationStackDestination = TestNavigatorDestination<TestGroupView>()
        let navView = TestGroupView(destination: navigationStackDestination)
        navigationStackDestination.assignAssociatedView(view: navView)
        
        let presentedDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        let thirdDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        if let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, navigationStackDestination], tabTypes: [.home, .group], selectedTab: .home) {
            
            try? tabsDestination.presentDestination(destination: presentedDestination, in: .group)
            
            try? tabsDestination.presentDestination(destination: thirdDestination, in: .group)

            XCTAssertTrue(tabsDestination.childDestinations().contains { $0.id == presentedDestination.id })
                    
            XCTAssertEqual(navigationStackDestination.childDestinations().count, 2, "Expected 2 Destinations in NavigationStack, but found \(navigationStackDestination.childDestinations().count)")
            
            try? tabsDestination.updateSelectedTab(type: .home)

            try? tabsDestination.updateSelectedTab(type: .group)
            
            XCTAssertEqual(tabsDestination.currentChildDestination()?.id, thirdDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination.currentChildDestination()?.type))")
            
            // currentDestination should find the current Destination
            let current = tabsDestination.currentDestination(for: .group)
            XCTAssertEqual(current?.id, thirdDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")
            
        } else {
            XCTFail("TabViewDestination was not created")
        }
    }
    
    
    func test_currentDestination_for_non_group_destination() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        let current = tabsDestination?.currentDestination(for: .home)
        XCTAssertEqual(current?.id, homeDestination.id)
    }
    
    func test_currentDestination_for_group_destination() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.home)
        let navigationStackDestination = TestNavigatorDestination<TestGroupView>()
        let navView = TestGroupView(destination: navigationStackDestination)
        navigationStackDestination.assignAssociatedView(view: navView)
        
        let childDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        let thirdDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, navigationStackDestination], tabTypes: [.home, .group], selectedTab: .home)
        try? tabsDestination?.presentDestination(destination: childDestination, in: .group)
        
        let current = tabsDestination?.currentDestination(for: .group)
        
        // currentDestination should find the current Destination
        XCTAssertEqual(current?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")
        
        XCTAssertEqual(tabsDestination?.currentChildDestination()?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination?.currentChildDestination()?.type))")
        
        try? tabsDestination?.presentDestination(destination: thirdDestination, in: .group)

        XCTAssertEqual(tabsDestination?.currentChildDestination()?.id, thirdDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination?.currentChildDestination()?.type))")
        
        navigationStackDestination.navigateBackInStack()
        navigationStackDestination.removeChild(identifier: thirdDestination.id)
        
        XCTAssertEqual(tabsDestination?.currentChildDestination()?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination?.currentChildDestination()?.type))")
        
        navigationStackDestination.navigateBackInStack()
        navigationStackDestination.removeChild(identifier: childDestination.id)

        XCTAssertEqual(tabsDestination?.currentChildDestination()?.id, navigationStackDestination.id, "Expected the child Destination to be the NavigationStack Destination, but the current is \(String(describing: tabsDestination?.currentChildDestination()?.type))")
    }
    
    func test_rootDestination_for_tab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.home)
        let navigationStackDestination = TestNavigatorDestination<TestGroupView>()
        let navView = TestGroupView(destination: navigationStackDestination)
        navigationStackDestination.assignAssociatedView(view: navView)
        
        let childDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, navigationStackDestination], tabTypes: [.home, .group], selectedTab: .home)
        try? tabsDestination?.presentDestination(destination: childDestination, in: .group)
        
        let homeRoot = tabsDestination?.rootDestination(for: .home)

        XCTAssertEqual(homeRoot?.id, homeDestination.id, "Expected the Home Destination to be the root, but the current is \(String(describing: homeRoot?.type))")
        
        let groupRoot = tabsDestination?.rootDestination(for: .group)
        
        XCTAssertEqual(groupRoot?.id, navigationStackDestination.id, "Expected the NavigationStack Destination to be the root, but the current is \(String(describing: groupRoot?.type))")

    }
    

    func test_destinationIdentifier_for_tab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        let identifier = tabsDestination?.destinationIdentifier(for: .home)
        
        XCTAssertEqual(identifier, homeDestination.id)
    }
    
    func test_updateTabViews() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let newDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let tabsDestination = TabViewDestination<TestTabView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        
        tabsDestination?.updateTabViews(destinationIDs: [newDestination.id, groupDestination.id], for: [TabModel(type: TestTabType.home), TabModel(type: TestTabType.group)])
        
        XCTAssertEqual(tabsDestination?.destinationIDsForTabs[.home], newDestination.id)
    }
}
