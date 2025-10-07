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
    
    func test_replaceCurrent_for_root_destination() {
        let startingDestination = PresentationConfiguration(destinationType: .home, presentationType: .replaceCurrent, assistantType: .basic)
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
                
        let newDestination = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination {
            XCTAssertEqual(currentDestination.type, .colorDetail)
            XCTAssertEqual(appFlow.rootDestination?.type, .colorDetail)
            XCTAssertEqual(appFlow.activeDestinations.count, 1)
        } else {
            XCTFail("Expected destination to be .colorDetail, got \(type(of: appFlow.currentDestination))")
        }
    }
    
    func test_replaceRoot() {
        
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
        
        let newDestination = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceRoot, assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination {
            XCTAssertEqual(currentDestination.type, .colorDetail)
            XCTAssertEqual(appFlow.rootDestination?.type, .colorDetail)
            XCTAssertEqual(appFlow.activeDestinations.count, 1)
        } else {
            XCTFail("Expected destination to be .colorDetail, got \(type(of: appFlow.currentDestination))")
        }
    }
    
    func test_add_to_navigation_stack_with_destination_path() {
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType =  .tabBar(tabs: startingTabs)
 
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes),  assistantType: .basic)
        ]
        
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, startingTabs: startingTabs)
        appFlow.start()
                
        let path: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .magenta, name: "magenta")), assistantType: .basic),
            PresentationConfiguration(destinationType: .home, presentationType: .navigationStack(type: .present),  assistantType: .basic)
        ]
        
        let newDestination = PresentationConfiguration(presentationType: .destinationPath(path: path), assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination as? any ViewDestinationable<DestinationType, ContentType, TabType>, let currentView = currentDestination.view {
            XCTAssertEqual(currentDestination.type, .home)
            XCTAssertEqual(appFlow.activeDestinations.count, 7)
            XCTAssertTrue(currentView is HomeView)
        } else {
            XCTFail("Expected destination to be .home, got \(type(of: appFlow.currentDestination))")
        }
    }
    
    func test_replaceRoot_with_destination_path() {
        
        let startingDestination = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
                
        let path: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorsList, presentationType: .replaceRoot, assistantType: .basic),
            PresentationConfiguration(destinationType: .home, presentationType: .navigationStack(type: .present),  assistantType: .basic)
        ]
        
        let newDestination = PresentationConfiguration(presentationType: .destinationPath(path: path), assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination {
            XCTAssertEqual(currentDestination.type, .home)
            XCTAssertEqual(appFlow.rootDestination?.type, .colorsList)
            XCTAssertEqual(appFlow.activeDestinations.count, 2)
        } else {
            XCTFail("Expected destination to be .home, got \(type(of: appFlow.currentDestination))")
        }
    }
    
    func test_replaceRoot_with_destination_path_and_tabbar() {
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType =  .tabBar(tabs: startingTabs)
 
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceRoot, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, startingTabs: startingTabs)
        appFlow.start()
                
        let path: [PresentationConfiguration] = [
            startingDestination,
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .home, presentationType: .navigationStack(type: .present),  assistantType: .basic)
        ]
        
        let newDestination = PresentationConfiguration(presentationType: .destinationPath(path: path), assistantType: .basic)
        appFlow.presentDestination(configuration: newDestination)
        
        if let currentDestination = appFlow.currentDestination {
            XCTAssertEqual(currentDestination.type, .home)
            XCTAssertEqual(appFlow.rootDestination?.type, .tabBar(tabs: startingTabs))
            XCTAssertEqual(appFlow.activeDestinations.count, 5, "Expected 6 active destinations, got \(appFlow.activeDestinations.map { $0.type })")
        } else {
            XCTFail("Expected destination to be .home, got \(type(of: appFlow.currentDestination))")
        }
    }
}
