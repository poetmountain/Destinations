//
//  DestinationableTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class DestinationableTests: XCTestCase, DestinationTypes {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }


    func test_access_presentation() {
        let startingType: RouteDestinationType = .colorsList
        let startingPresentation = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .basic)

        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        
        let appFlow = ViewFlow(destinationProviders: [.colorsList: colorsListProvider], startingDestination: startingPresentation)
        appFlow.start()
        
        if let destination = appFlow.currentDestination as? ColorsListDestination {
            
            let presentation = destination.presentation(for: ColorsListDestination.UserInteractions.color(model: nil))
            XCTAssertNotNil(presentation)
            
        } else {
            XCTFail("No root destination, found \(String(describing: appFlow.rootDestination?.type))")
        }
    }
    
    func test_access_system_navigation_presentation() {
        let startingType: RouteDestinationType = .colorsList
        let startingPresentation = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)

        let colorsListProvider = ColorsListProvider()
        
        let appFlow = ViewFlow(destinationProviders: [.colorsList: colorsListProvider], startingDestination: startingPresentation)
        appFlow.start()
        
        if let destination = appFlow.currentDestination as? ColorsListDestination {
            let presentation = destination.systemNavigationPresentation(for: .navigateBackInStack)
            XCTAssertNotNil(presentation)

        } else {
            XCTFail("No root destination, found \(String(describing: appFlow.rootDestination))")
        }
    }
    
    func test_update_presentation() {
        let startingType: RouteDestinationType = .colorsList
        let startingPresentation = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .basic)

        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        
        let appFlow = ViewFlow(destinationProviders: [.colorsList: colorsListProvider], startingDestination: startingPresentation)
        appFlow.start()
        
        if let destination = appFlow.currentDestination as? ColorsListDestination {
            if let presentation = destination.presentation(for: .color(model: nil)){
                let newParentID = UUID()
                presentation.parentDestinationID = newParentID
                destination.updatePresentation(presentation: presentation)
                
                XCTAssertEqual(destination.presentation(for: .color(model: nil))?.parentDestinationID, newParentID)
            } else {
                XCTFail("Presentation not found")
            }
        } else {
            XCTFail("No root destination, found \(String(describing: appFlow.rootDestination))")
        }
    }
    
    func test_update_system_navigation_presentation() {
        let startingType: RouteDestinationType = .colorsList
        let startingPresentation = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)

        let colorsListProvider = ColorsListProvider()
        
        let appFlow = ViewFlow(destinationProviders: [.colorsList: colorsListProvider], startingDestination: startingPresentation)
        appFlow.start()
        
        if let destination = appFlow.currentDestination as? ColorsListDestination {
            if let presentation = destination.systemNavigationPresentation(for: .navigateBackInStack) {
                let newTargetID = UUID()
                presentation.actionTargetID = newTargetID
                destination.updateSystemNavigationPresentation(presentation: presentation)
                
                XCTAssertEqual(destination.systemNavigationPresentation(for: .navigateBackInStack)?.actionTargetID, newTargetID)
                
            } else {
                XCTFail("Could not find presentation")
            }
            
        } else {
            XCTFail("No root destination, found \(String(describing: appFlow.rootDestination))")
        }
    }
    
    func test_buildInterfaceAction() {
        let startingType: RouteDestinationType = .colorsList
        let startingPresentation = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .basic)

        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        
        let appFlow = ViewFlow(destinationProviders: [.colorsList: colorsListProvider], startingDestination: startingPresentation)
        appFlow.start()
        
        if let destination = appFlow.currentDestination as? ColorsListDestination {
            let colorButtonSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic)
            let interfaceAction = destination.buildInterfaceAction(presentationClosure: { _ in }, configuration: colorButtonSelection, interactionType: .color(model: nil))
            
            XCTAssertEqual(interfaceAction.userInteractionType, .color(model: nil))
            XCTAssertEqual(interfaceAction.data.destinationType, colorButtonSelection.destinationType)
            XCTAssertEqual(interfaceAction.data.presentationID, colorButtonSelection.id)
            
            interfaceAction()

        } else {
            XCTFail("No root destination, found \(String(describing: appFlow.rootDestination))")
        }
    }
    
    func test_buildSystemNavigationAction() {
        let startingType: RouteDestinationType = .colorsList
        let startingPresentation = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .basic)

        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        
        let appFlow = ViewFlow(destinationProviders: [.colorsList: colorsListProvider], startingDestination: startingPresentation)
        appFlow.start()
        
        if let destination = appFlow.currentDestination as? ColorsListDestination {
            
            let sheetDismiss = PresentationConfiguration(presentationType: .sheet(type: .dismiss), actionType: .systemNavigation, assistantType: .basic)
            let systemSelection = destination.buildSystemNavigationAction(presentationClosure: { _ in }, configuration: sheetDismiss, navigationType: .navigateBackInStack)
            
            XCTAssertEqual(systemSelection.userInteractionType, .navigateBackInStack)
            XCTAssertEqual(systemSelection.data.actionType, .systemNavigation)
            XCTAssertEqual(systemSelection.data.presentationID, sheetDismiss.id)
            
        } else {
            XCTFail("No root destination, found \(String(describing: appFlow.rootDestination))")
        }
    }
    
    func test_performRequest() {
        
        let expectation = expectation(description: "Performs a request and tests the result in the closure")

        let destination = ViewDestination<HomeView.UserInteractions, HomeView, PresentationConfiguration>(destinationType: .home)
        let view = HomeView(destination: destination)
        destination.assignAssociatedView(view: view)
        
        let interactor = TestInteractor()
        
        destination.setupInteractor(interactor: interactor, for: .test)
        
        let request = TestRequest(action: .increaseCount)
        
        destination.performRequest(interactor: .test, request: request) { result in
            switch result {
                case .success(let data):
                    XCTAssertEqual(data.first, 1, "Expected request result to equal 1, got \(String(describing: data.first))")
                case .failure(let error):
                    XCTFail("Request failed: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func test_addInterfaceAction() {
        let destination = ColorsListDestination()
        let listView = ColorsListView(destination: destination)
        destination.assignAssociatedView(view: listView)
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .basic)

        let interactionType = ColorsListDestination.UserInteractions.color(model: nil)
        let interfaceAction = destination.buildInterfaceAction(presentationClosure: { _ in }, configuration: colorSelection, interactionType: interactionType)
        
        try? destination.addInterfaceAction(action: interfaceAction)
        
        XCTAssertNotNil(destination.interfaceActions[interactionType])
    }
    
    func test_addSystemNavigationClosure() {

        let destination = ColorsListDestination()
        let listView = ColorsListView(destination: destination)
        destination.assignAssociatedView(view: listView)

        let backSelection = PresentationConfiguration(presentationType: .navigationController(type: .goBack), actionType: .systemNavigation, assistantType: .basic)
        let systemAction = destination.buildSystemNavigationAction(presentationClosure: { _ in }, configuration: backSelection, navigationType: .navigateBackInStack)
        
        destination.addSystemNavigationAction(action: systemAction)
        
        XCTAssertNotNil(destination.systemNavigationActions[SystemNavigationType.navigateBackInStack])
    }
}
