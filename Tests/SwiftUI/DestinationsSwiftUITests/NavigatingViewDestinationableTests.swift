//
//  NavigatingViewDestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class NavigatingViewDestinationableTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addChild() {
        let destination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let navDestination = TestGroupDestination()
        
        navDestination.addChild(childDestination: destination)
        
        XCTAssertTrue(navDestination.childDestinations.contains(where: { $0.id == destination.id}))
    }
    
    func test_replaceChild() {
        let destination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let navDestination = TestNavigatorDestination()
        
        navDestination.addChild(childDestination: destination)
        
        let newDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        
        navDestination.replaceChild(currentID: destination.id, with: newDestination)
    }

    func test_removeChild() {
        let destination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let navDestination = TestNavigatorDestination()
        let navView = TestGroupView(destination: navDestination)
        navDestination.assignAssociatedView(view: navView)
        
        navDestination.addChild(childDestination: destination)
        
        navDestination.removeChild(identifier: destination.id)

        XCTAssertEqual(navDestination.childDestinations.count, 0)
        
        XCTAssertNil(navDestination.currentChildDestination)
                
        XCTAssertNil(navDestination.navigator()?.currentPresentationID, "currentPresentationID was expected to be nil, but found \(String(describing: navDestination.navigator()?.currentPresentationID))")
    }
}