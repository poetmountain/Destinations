//
//  SwiftUIContainerDestinationTests.swift
//  DestinationsUIKitTests
//
//  Created by Brett Walker on 2/2/25.
//

import XCTest
import UIKit
@testable import DestinationsUIKit
@testable import Destinations

@MainActor final class SwiftUIContainerDestinationTests: XCTestCase, DestinationTypes {
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .verbose
    }

    override func tearDown() async throws {
        sceneDelegate?.navigationController.setViewControllers([], animated: false)
        sceneDelegate?.navigationController = UINavigationController()
        sceneDelegate?.window?.rootViewController = sceneDelegate?.createRootViewController()
    }

    func test_setup_SwiftUIContainer() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorNav, presentationType: .addToCurrent, assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let colorContainerProvider = ColorsDetailContainerProvider()
        let startProvider = StartProvider()
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .colorNav: colorContainerProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignRoot(rootController: root)
        }
        appFlow.start()
                
        let swiftUIContainerDestination = try? XCTUnwrap(appFlow.currentDestination as? any SwiftUIContainerDestinationable<DestinationType, ContentType, TabType>, "expected a SwiftUIContainerDestination but found \(String(describing: appFlow.currentDestination))")
        
        XCTAssertEqual(swiftUIContainerDestination?.viewFlow?.activeDestinations.count, 1, "Expected only ColorNavDestination, but found \(String(describing: swiftUIContainerDestination?.viewFlow?.activeDestinations.map { $0.type }))")
        XCTAssertEqual(swiftUIContainerDestination?.viewFlow?.currentDestination?.type, .colorNav)
        
    }

    func test_present_new_destination_on_SwiftUI_NavigationStack() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorNav, presentationType: .addToCurrent, assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        
        let colorContainerProvider = ColorsDetailContainerProvider()
        let startProvider = StartProvider()
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .colorNav: colorContainerProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignRoot(rootController: root)
        }
        appFlow.start()
                
        let swiftUIContainerDestination = try? XCTUnwrap(appFlow.currentDestination as? any SwiftUIContainerDestinationable<DestinationType, ContentType, TabType>, "expected a SwiftUIContainerDestination but found \(String(describing: appFlow.currentDestination))")
        
        
        let swiftUINavDestination = try? XCTUnwrap(swiftUIContainerDestination?.viewFlow?.currentDestination as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType>, "expected a NavigatingViewDestinationable object but found \(String(describing: appFlow.currentDestination?.type))")
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetailSwiftUI,
                                                       presentationType: .navigationStack(type: .present),
                                                       contentType: .color(model: ColorViewModel(color: .blue)),
                                                       assistantType: .custom(ChooseColorFromListActionAssistant()))
        
        appFlow.presentDestination(configuration: colorSelection)
        
        wait(timeout: 0.3)

        XCTAssertEqual(swiftUIContainerDestination?.viewFlow?.activeDestinations.count, 2, "Expected ColorNavDestination and ColorDetailSwiftUIDestination, but found \(String(describing: swiftUIContainerDestination?.viewFlow?.activeDestinations.map { $0.type }))")
        XCTAssertEqual(swiftUIContainerDestination?.viewFlow?.currentDestination?.type, .colorDetailSwiftUI)

        XCTAssertEqual(swiftUINavDestination?.navigator()?.navigationPath.count, 1)
    }
}
