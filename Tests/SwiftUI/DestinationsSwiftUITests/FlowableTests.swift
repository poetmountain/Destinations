//
//  FlowableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest

@testable import DestinationsSwiftUI
import Destinations

@MainActor final class FlowableTests: XCTestCase, DestinationTypes {

    override func setUpWithError() throws {
        continueAfterFailure = false

    }

    func test_presenting_destination() {

        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        if let currentDestination = appFlow.currentDestination as? any NavigatingViewDestinationable & DestinationTypeable {
            XCTAssert(currentDestination.type == .colorsList)
        } else {
            XCTFail("Expected destination to be NavigatingDestinationable, got \(type(of: appFlow.currentDestination))")
        }
    }
    
    func test_presentDestination_and_preserve_navstack_state() {

        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, startingTabs: startingTabs)
        appFlow.start()
        
        wait(timeout: 0.3)
        
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic))
        
        if let presentedDestination = appFlow.currentDestination as? any ViewDestinationable<DestinationType, ContentType, TabType>, let tabsDestination = appFlow.findTabBarInViewHierarchy(searchDestination: presentedDestination) {
            
            XCTAssertEqual(presentedDestination.type, .colorDetail)
            
            try? tabsDestination.updateSelectedTab(type: .home)
            
            try? tabsDestination.updateSelectedTab(type: .palettes)
            
            XCTAssertEqual(tabsDestination.currentChildDestination()?.id, presentedDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: tabsDestination.currentChildDestination()?.type))")
            
            // currentDestination should find the current Destination
            XCTAssertEqual(appFlow.currentDestination?.id, presentedDestination.id, "Expected the child Destination to be the current one, but the current is \(String(describing: appFlow.currentDestination?.type))")
            
        } else {
            XCTFail()
        }

    }
    
    func test_destination_retrieval() {
        let startingType: RouteDestinationType = .colorDetail
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        guard let destinationID = appFlow.rootDestination?.id else {
            XCTFail("Starting destination wasn't created")
            return
        }

        let destination = appFlow.destination(for: destinationID)
        
        XCTAssertEqual(destination?.id, destinationID)
    }
    
    
    func test_updateCurrentDestination() {
        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        let newPresentation = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        guard let newDestination = appFlow.buildDestination(for: newPresentation) else {
            XCTFail("New destination wasn't created")
            return
        }
        
        appFlow.updateCurrentDestination(destination: newDestination)
        
        XCTAssertEqual(appFlow.currentDestination?.id, newDestination.id)
    }
    
    func test_updateActiveDestinations() {
        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        let newPresentation = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        guard let newDestination = appFlow.buildDestination(for: newPresentation) else {
            XCTFail("New destination wasn't created")
            return
        }
        
        appFlow.updateActiveDestinations(with: newDestination)
        
        XCTAssert(appFlow.activeDestinations.contains(where: { $0.id == newDestination.id}), "activeDestinations doesn't contain the new destination")
        
        appFlow.updateActiveDestinations(with: newDestination)

        XCTAssertEqual(appFlow.activeDestinations.count, 2, "Expected 1 active destination \(newDestination.id), but found \(appFlow.activeDestinations.map { $0.id })")
    }
    
    
    
    func test_switch_tab() {
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)

        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, startingTabs: startingTabs)
        appFlow.start()

                
        // switch tab to Home
        appFlow.presentDestination(configuration: PresentationConfiguration(presentationType: .tabBar(tab: .home), assistantType: .basic))
        
        XCTAssertEqual(appFlow.currentDestination?.type, .home)
        
    }
    
    
    
    func test_removeDestination() {
        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        guard let colorsListDestination = appFlow.currentDestination as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType> else {
            XCTFail("No current destination found")
            return
        }
        
        let childDestination = ColorDetailDestination()
        colorsListDestination.addChild(childDestination: childDestination)
        
        appFlow.removeDestination(destinationID: colorsListDestination.id)
        
        XCTAssertNil(appFlow.activeDestinations.first(where: { $0.id == colorsListDestination.id} ), "Expected destination to not be in activeDestinations")
        
        XCTAssertEqual(colorsListDestination.childDestinations().count, 0, "Expected all children to be removed")
        
        XCTAssertNil(appFlow.currentDestination, "Expected no currentDestination, but found \(String(describing: appFlow.currentDestination?.id))")
    }
    
    
    func test_replaceDestination_in_tabview() {
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, startingTabs: startingTabs)
        appFlow.start()
        
        // switch tab to Home
        appFlow.presentDestination(configuration: PresentationConfiguration(presentationType: .tabBar(tab: .home), assistantType: .basic))
                
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic))
                            
        XCTAssertEqual(appFlow.activeDestinations.count(where: { $0.type == .colorDetail }), 1)
        XCTAssertEqual(appFlow.activeDestinations.count(where: { $0.type == .home }), 0)
            
    }
    
    func test_replaceDestination_in_splitview() {
        
        let startingType: RouteDestinationType = .splitView
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination, splitViewContent: [.sidebar: .colorsList, .detail: .colorDetail])
        appFlow.start()
        
        // replace Destination in detail column
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .splitView(column: SplitViewColumn(swiftUI: .detail)), contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic))
                            
        // SplitView started with one colorDetail, so presenting a new colorDetail in that column should replace it
        XCTAssertEqual(appFlow.activeDestinations.count(where: { $0.type == .colorDetail }), 1)
            
    }
    
    func test_replaceDestination_in_navigation_stack() {
        
        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        guard let navDestination = appFlow.activeDestinations.first(where: { $0.type == .colorsList }) as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType>, let destination = appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic)) else {
            
            XCTFail("No nav destination found")
            return
        }
        
        let currentIndex = navDestination.childDestinations().firstIndex(where: { $0.id == destination.id })
        
        guard let newDestination = appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic)) else {
            XCTFail("New Destination not presented")
            return
        }
                    
        let newIndex = navDestination.childDestinations().firstIndex(where: { $0.id == newDestination.id })
        
        XCTAssertEqual(currentIndex, newIndex)
        
        guard let newDestination2 = appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic)) else {
            XCTFail("New Destination 2 not presented")
            return
        }
                    
        let newIndex2 = navDestination.childDestinations().firstIndex(where: { $0.id == newDestination2.id })
        
        XCTAssertEqual(newIndex, newIndex2)
            
    }
    
    func test_presentDestinationPath() {

        let startingType: RouteDestinationType = .colorsList
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let appFlow = TestHelpers.buildAppFlow(startingDestination: startingDestination)
        appFlow.start()
        
        let path: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .orange, name: "orange")), assistantType: .basic)
        ]
        
        appFlow.presentDestinationPath(path: path)

        XCTAssertEqual(appFlow.activeDestinations.count, 3, "expected activeDestinations to have 3 destinations, but contains \(appFlow.activeDestinations.count)")
        XCTAssertEqual(appFlow.currentDestination?.type, .colorDetail)
    }
    
    

}
