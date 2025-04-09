//
//  NavigationSplitViewDestinationableTests.swift
//  DestinationsSwiftUITests
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class NavigationSplitViewDestinationableTests: XCTestCase, DestinationTypes {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func test_column_for_destinationID() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .detail)
        let groupDestination = TestGroupDestination()
        
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: groupDestination, .content: homeDestination])
        
        let groupColumn = splitViewDestination.column(destinationID: groupDestination.id)
        XCTAssertEqual(groupColumn, .sidebar)
        
        let homeColumn = splitViewDestination.column(destinationID: homeDestination.id)
        XCTAssertEqual(homeColumn, .content)
        
    }

    func test_replaceChild() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let newDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: groupDestination, .content: homeDestination])
            
        splitViewDestination.replaceChild(currentID: homeDestination.id, with: newDestination)
        
        // new Destination should be a child
        XCTAssertTrue(splitViewDestination.childDestinations().contains { $0.id == newDestination.id })
        
        // home Destination should not be a child
        XCTAssertFalse(splitViewDestination.childDestinations().contains { $0.id == homeDestination.id })

        // new Destination should be the new current
        XCTAssertEqual(splitViewDestination.currentChildDestination()?.id, newDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: splitViewDestination.currentChildDestination()?.type))")
        
        // currentDestination should find the current Destination
        let current = splitViewDestination.currentDestination(for: .content)
        XCTAssertEqual(current?.id, newDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")

    }
    
    func test_presentDestination_in_single_view_column() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        let presentedDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.replacement)
        
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: groupDestination, .content: homeDestination])
                    
        splitViewDestination.presentDestination(destination: presentedDestination, in: .content)
        
        XCTAssertTrue(splitViewDestination.childDestinations().contains { $0.id == presentedDestination.id })

        // currentDestination should find the current Destination
        let current = splitViewDestination.currentDestination(for: .content)
        XCTAssertEqual(current?.id, presentedDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")

        
    }
    
    func test_presentDestination_in_navigationStack_column() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navigatorDestination = TestNavigatorDestination<TestGroupView>()
        let groupView = TestGroupView(destination: navigatorDestination)
        navigatorDestination.assignAssociatedView(view: groupView)
        
        let firstDetailDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.replacement)
        let secondDetailDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.replacement)
        
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestSplitView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: homeDestination, .content: navigatorDestination])
        let view = TestSplitView(destination: splitViewDestination)
        splitViewDestination.assignAssociatedView(view: view)
                    
        splitViewDestination.presentDestination(destination: firstDetailDestination, in: .content)
        XCTAssertTrue(splitViewDestination.childDestinations().contains { $0.id == firstDetailDestination.id })

        splitViewDestination.presentDestination(destination: secondDetailDestination, in: .content)
        XCTAssertTrue(splitViewDestination.childDestinations().contains { $0.id == secondDetailDestination.id })

        // sidebar view + navigator view + 2 of its children = 4
        XCTAssertEqual(splitViewDestination.childDestinations().count, 4)

        // navigator in the content column should have 2 children
        XCTAssertEqual(navigatorDestination.childDestinations().count, 2)
    }
    
    func test_currentDestination_for_non_group_destination() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
 
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestSplitView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: groupDestination, .content: homeDestination])
        
        let current = splitViewDestination.currentDestination(for: .content)
        XCTAssertEqual(current?.id, homeDestination.id)
    }
    
    func test_currentDestination_for_group_destination() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navigatorDestination = TestNavigatorDestination<TestGroupView>()
        let groupView = TestGroupView(destination: navigatorDestination)
        navigatorDestination.assignAssociatedView(view: groupView)
        
        let firstDetailDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.replacement)
  
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestSplitView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: homeDestination, .content: navigatorDestination])
        let view = TestSplitView(destination: splitViewDestination)
        splitViewDestination.assignAssociatedView(view: view)
        
        splitViewDestination.presentDestination(destination: firstDetailDestination, in: .content)

        
        let childDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        
        splitViewDestination.presentDestination(destination: childDestination, in: .content)

        let current = splitViewDestination.currentDestination(for: .content)
        
        // currentDestination should find the current Destination
        XCTAssertEqual(current?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: current?.type))")
        
        XCTAssertEqual(splitViewDestination.currentChildDestination()?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: splitViewDestination.currentChildDestination()?.type))")
        
        let secondDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        splitViewDestination.presentDestination(destination: secondDestination, in: .content)
        
        XCTAssertEqual(splitViewDestination.currentChildDestination()?.id, secondDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: splitViewDestination.currentChildDestination()?.type))")
        
        navigatorDestination.navigateBackInStack()
        navigatorDestination.removeChild(identifier: secondDestination.id)
        
        XCTAssertEqual(splitViewDestination.currentChildDestination()?.id, childDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: splitViewDestination.currentChildDestination()?.type))")
    }
    
    func test_rootDestination_for_column() {
        let homeDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navigatorDestination = TestNavigatorDestination<TestGroupView>()
        let groupView = TestGroupView(destination: navigatorDestination)
        navigatorDestination.assignAssociatedView(view: groupView)
        
        let firstDetailDestination = ViewDestination<TestView, TestView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.replacement)
  
        let splitViewDestination = NavigationSplitViewDestination<TestSplitView, TestSplitView.UserInteractions, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: .splitView, destinationsForColumns: [.sidebar: homeDestination, .content: navigatorDestination])
        let view = TestSplitView(destination: splitViewDestination)
        splitViewDestination.assignAssociatedView(view: view)
        
        splitViewDestination.presentDestination(destination: firstDetailDestination, in: .content)
        
        let homeRoot = splitViewDestination.rootDestination(for: .sidebar)

        XCTAssertEqual(homeRoot?.id, homeDestination.id, "Expected the Home Destination to be the root, but the current is \(String(describing: homeRoot?.type))")
        
        let groupRoot = splitViewDestination.rootDestination(for: .content)
        
        XCTAssertEqual(groupRoot?.id, navigatorDestination.id, "Expected the NavigationStack Destination to be the root, but the current is \(String(describing: groupRoot?.type))")

    }
}
