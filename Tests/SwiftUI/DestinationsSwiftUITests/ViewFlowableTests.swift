//
//  ViewFlowableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class ViewFlowableTests: XCTestCase, DestinationTypes {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_findNavigatorInViewHierarchy() {
        
        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        let path: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .orange, name: "orange")), assistantType: .basic)
        ]
        
        appFlow.presentDestinationPath(path: path)
        
        if let lastDestination = appFlow.activeDestinations.last as? any ViewDestinationable {
            let navigator = appFlow.findNavigatorInViewHierarchy(searchDestination: lastDestination)
    
            XCTAssertNotNil(navigator, "Could not find navigator")
        } else {
            XCTFail("No last destination found")
        }
    }
    
    func test_findTabBarInViewHierarchy() {
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, startingTabs: startingTabs)
        appFlow.start()
        
        let path: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .orange, name: "orange")), assistantType: .basic)
        ]
        
        appFlow.presentDestinationPath(path: path)
        
        if let lastDestination = appFlow.activeDestinations.last as? any ViewDestinationable {
            let tabBar = appFlow.findTabBarInViewHierarchy(searchDestination: lastDestination)
    
            XCTAssertNotNil(tabBar, "Could not find tab bar")
        } else {
            XCTFail("No last destination found, \(appFlow.activeDestinations.map { $0.type })")
        }
    }
    
}
