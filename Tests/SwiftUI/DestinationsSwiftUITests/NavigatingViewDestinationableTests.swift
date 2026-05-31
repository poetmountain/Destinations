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

@MainActor final class NavigatingViewDestinationableTests: XCTestCase, DestinationTypes {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
    }
    
    func test_addChild() {
        let destination = ViewDestination<TestView, TestView.Events, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navDestination = TestGroupDestination()
        
        navDestination.addChild(childDestination: destination)
        
        XCTAssertTrue(navDestination.childDestinations().contains(where: { $0.id == destination.id}))
    }
    

    func test_removeChild() {
        let destination = ViewDestination<TestView, TestView.Events, TestDestinationType, ContentType, TestTabType, InteractorType>(destinationType: TestDestinationType.detail)
        let navDestination = TestNavigatorDestination<TestGroupView>()
        let navView = TestGroupView(destination: navDestination)
        navDestination.assignAssociatedView(view: navView)
        
        navDestination.addChild(childDestination: destination)
        
        navDestination.removeChild(identifier: destination.id, removeDestinationFromFlowClosure: nil)

        XCTAssertEqual(navDestination.childDestinations().count, 0)
        
        XCTAssertNil(navDestination.currentChildDestination())
                
        XCTAssertNil(navDestination.navigator()?.currentPresentationID, "currentPresentationID was expected to be nil, but found \(String(describing: navDestination.navigator()?.currentPresentationID))")
    }
}
