//
//  GroupedDestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class GroupedDestinationableTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addChild() {
        let childDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        
        XCTAssertTrue(groupDestination.childDestinations.contains(where: { $0.id == childDestination.id }))
        XCTAssertEqual(childDestination.parentDestinationID, groupDestination.id, "Expected child Destination to have parent ID of the group")
    }
    
    func test_removeChild() {
        let childDestination = TestGroupDestination()
        
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        groupDestination.currentChildDestination = childDestination
        
        groupDestination.removeChild(identifier: childDestination.id)
        
        XCTAssertFalse(groupDestination.childDestinations.contains(where: { $0.id == childDestination.id }), "Expected that the group no longer contained the child, but it was still present..")
        
        XCTAssertNil(groupDestination.currentChildDestination, "The removeChild method was expected to remove the currentChildDestination reference")
        
        XCTAssertEqual(childDestination.childDestinations.count, 0, "The child group Destination was expected to have no children after being removed, but \(childDestination.childDestinations.count) children were found.")
    }
    
    func test_removeAllChildren() {
        let childDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let child2Destination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        groupDestination.addChild(childDestination: child2Destination)
        
        groupDestination.removeAllChildren()
        
        XCTAssertEqual(groupDestination.childDestinations.count, 0, "The child Destination was expected to have no children after being removed, but \(groupDestination.childDestinations.count) children were found.")
    }
    
    func test_childForIdentifier() {
        let childDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        
        let resultChild = groupDestination.childForIdentifier(destinationIdentifier: childDestination.id)
        
        XCTAssertNotNil(resultChild, "Expected that childForIdentifier() would return a child Destination, but found nil.")
    }
    
    func test_replaceCurrentDestination_with_existing_destination() {
        
        let childDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let newDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.list)
        
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        groupDestination.currentChildDestination = childDestination
                
        groupDestination.replaceCurrentDestination(with: newDestination)
        
        XCTAssertEqual(groupDestination.currentChildDestination?.id, newDestination.id, "Expected the Destination with the current focus to be the new Destination")
    }
    
    func test_replaceCurrentDestination_with_no_current_destination() {
        
        let newDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.list)
        
        let groupDestination = TestGroupDestination()
        groupDestination.replaceCurrentDestination(with: newDestination)
        
        XCTAssertEqual(groupDestination.currentChildDestination?.id, newDestination.id, "Expected the Destination with the current focus to be the new Destination")
    }
    
    func test_replaceChild() {
        let childDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let child2Destination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let child3Destination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let newDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.list)
        
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        groupDestination.addChild(childDestination: child2Destination)
        groupDestination.addChild(childDestination: child3Destination)

        let currentIndex = groupDestination.childDestinations.firstIndex(where: { $0.id == child2Destination.id })
        
        groupDestination.replaceChild(currentID: child2Destination.id, with: newDestination)
        
        let newIndex = groupDestination.childDestinations.firstIndex(where: { $0.id == newDestination.id })

        XCTAssertEqual(currentIndex, newIndex)
        
        let newDestination2 = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.list)
        let currentIndex2 = groupDestination.childDestinations.firstIndex(where: { $0.id == child3Destination.id })
        
        groupDestination.replaceChild(currentID: child3Destination.id, with: newDestination2)
        
        let newIndex2 = groupDestination.childDestinations.firstIndex(where: { $0.id == newDestination2.id })
        
        XCTAssertEqual(currentIndex2, newIndex2)

    }
    
    func test_updateCurrentDestination() {
        let childDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.detail)
        let newDestination = ViewDestination<TestView.UserInteractions, TestView, TestView.PresentationConfiguration>(destinationType: TestDestinationType.list)
        let groupDestination = TestGroupDestination()
        groupDestination.addChild(childDestination: childDestination)
        groupDestination.addChild(childDestination: newDestination)
        groupDestination.currentChildDestination = childDestination
        
        groupDestination.updateCurrentDestination(destinationID: newDestination.id)
        
        XCTAssertEqual(groupDestination.currentChildDestination?.id, newDestination.id)
    }
    
}
