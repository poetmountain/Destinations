//
//  DestinationPathNavigatingTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class DestinationPathNavigatingTests: XCTestCase {
    

    func test_addPathElement() {
        let pathID = UUID()
        let navigator = DestinationNavigator()
        navigator.addPathElement(item: pathID)
        
        XCTAssertEqual(navigator.currentPathElement(), pathID)
    }

    func test_backToPrevious() {
        let pathID = UUID()
        let secondPathID = UUID()
        let presentationID = UUID()
        let secondPresentationID = UUID()
        let navigator = DestinationNavigator()
        navigator.addPathElement(item: pathID)
        navigator.addPathElement(item: secondPathID)
        
        navigator.backToPreviousPathElement(previousPresentationID: presentationID)
        
        XCTAssertEqual(navigator.navigationPath.count, 1)
        XCTAssertEqual(navigator.currentPresentationID, presentationID)
        
        navigator.backToPreviousPathElement(previousPresentationID: secondPresentationID)
        
        XCTAssertEqual(navigator.navigationPath.count, 0)
        XCTAssertEqual(navigator.currentPresentationID, secondPresentationID)
    }
    
    func test_removeAll() {
        let pathID = UUID()
        let navigator = DestinationNavigator()
        navigator.addPathElement(item: pathID)

        navigator.removeAll()
        
        XCTAssertEqual(navigator.navigationPath.count, 0)

    }
    
    func test_previousPathElement() {
        let pathID = UUID()
        let navigator = DestinationNavigator()
        navigator.addPathElement(item: pathID)
        let secondElementID = UUID()
        navigator.addPathElement(item: secondElementID)
        
        let previous = navigator.previousPathElement()
        
        XCTAssertEqual(navigator.navigationPath[0], previous)

        
    }
}
