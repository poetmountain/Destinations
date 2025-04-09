//
//  TabBarViewDestinationInterfacingTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class TabBarViewDestinationInterfacingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_tabIndex_for_tab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestView.DestinationType, TestTabView.ContentType, TestView.TabType, TestView.InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestTabView.UserInteractions, TestTabView.DestinationType, TestTabView.ContentType, TestTabView.TabType, TestTabView.InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        let tabView = TestTabView(destination: tabsDestination!)
        tabsDestination?.assignAssociatedView(view: tabView)
        
        let index = tabView.tabIndex(for: TestTabType.home)
        
        XCTAssertNotNil(index)
    }

    func test_tab_for_destinationID() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestView.DestinationType, TestTabView.ContentType, TestView.TabType, TestView.InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestTabView.UserInteractions, TestTabView.DestinationType, TestTabView.ContentType, TestTabView.TabType, TestTabView.InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        let tabView = TestTabView(destination: tabsDestination!)
        tabsDestination?.assignAssociatedView(view: tabView)
        
        let tab = tabsDestination?.tab(destinationID: homeDestination.id)
        
        XCTAssertEqual(tab, .home)
    }
    
    func test_gotoTab() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestView.DestinationType, TestTabView.ContentType, TestView.TabType, TestView.InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestTabView.UserInteractions, TestTabView.DestinationType, TestTabView.ContentType, TestTabView.TabType, TestTabView.InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        let tabView = TestTabView(destination: tabsDestination!)
        tabsDestination?.assignAssociatedView(view: tabView)
        
        try? tabView.gotoTab(.group)
        
        XCTAssertEqual(tabsDestination?.selectedTab.type, TestTabType.group)

    }
    
    func test_replaceView() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestView.DestinationType, TestTabView.ContentType, TestView.TabType, TestView.InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let tabsDestination = TabViewDestination<TestTabView, TestTabView.UserInteractions, TestTabView.DestinationType, TestTabView.ContentType, TestTabView.TabType, TestTabView.InteractorType>(type: .tabBar, tabDestinations: [homeDestination, groupDestination], tabTypes: [.home, .group], selectedTab: .home)
        let tabView = TestTabView(destination: tabsDestination!)
        tabsDestination?.assignAssociatedView(view: tabView)
        
        let newDestination = ViewDestination<TestView, TestView.UserInteractions, TestView.DestinationType, TestTabView.ContentType, TestView.TabType, TestView.InteractorType>(destinationType: TestDestinationType.detail)
        
        tabView.replaceViews(in: .group, with: newDestination.id)
        
        XCTAssertEqual(tabsDestination?.destinationIDsForTabs[.group], newDestination.id)

    }
}
