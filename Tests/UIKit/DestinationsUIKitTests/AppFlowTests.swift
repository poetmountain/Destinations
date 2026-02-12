//
//  AppFlowTests.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import UIKit
@testable import DestinationsUIKit
import Destinations

@MainActor final class AppFlowTests: XCTestCase, DestinationTypes {
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
        
    let testDestinations = TestDestinations()

    override func tearDown() async throws {
        sceneDelegate?.navigationController.setViewControllers([], animated: false)
        sceneDelegate?.navigationController = UINavigationController()
        sceneDelegate?.window?.rootViewController = sceneDelegate?.createRootViewController()

    }


    func test_show_colors_VC() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        let startingDestination = PresentationConfiguration(destinationType: .colorsList, presentationType: .replaceCurrent, assistantType: .basic)
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController)
        appFlow.start()
        
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable, let controller = try? XCTUnwrap(currentDestination.currentController() as? TestColorsViewController, "couldn't find colors vc") {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.3)

            XCTAssert(currentDestination.type == .colorsList)
            
            if let items = controller.modelItems() {
                XCTAssert(items.count == 3, "expected 3 items, got \(items.count)")
            } else {
                XCTFail("No interactor found")
            }
            
            
        } else {
            XCTFail("no current destination, expected .colorsList")
        }
    }
    
    func test_request_more_colors() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        let startingDestination = PresentationConfiguration(destinationType: .colorsList, presentationType: .replaceCurrent, assistantType: .basic)
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController)
        appFlow.start()
        
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable, let controller = try? XCTUnwrap(currentDestination.currentController() as? TestColorsViewController, "couldn't find colors vc") {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.1)

            controller.requestMoreButtonAction()
            wait(timeout: 0.1)

            let newCount = controller.modelItems()?.count ?? 0
            XCTAssert(newCount == 5, "expected 5 items, got \(newCount)")

        } else {
            XCTFail("no current controller")
        }

    }

    func test_navbar_move_to_detail_VC() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        let startingDestination = PresentationConfiguration(destinationType: .colorsList, presentationType: .replaceCurrent, assistantType: .basic)
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController)
        appFlow.start()
        
        wait(timeout: 0.1)
        
        moveToDetailView(startingType: .colorsList, appFlow: appFlow)
    }
    
    func test_presentation_appearance_methods() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        let startingDestination = PresentationConfiguration(destinationType: .colorsList, presentationType: .replaceCurrent, assistantType: .basic)
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController)
        appFlow.start()
        
        wait(timeout: 0.3)
        
        let path: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .orange, name: "orange")), assistantType: .basic)
        ]
        
        appFlow.presentDestinationPath(path: path)
        
        wait(timeout: 0.3)
        
        if let presentedDestination = appFlow.currentDestination as? ColorDetailDestination {
            XCTAssertTrue(presentedDestination.didAppear)
            XCTAssertTrue(presentedDestination.isVisible)
        } else {
            XCTFail()
        }

        // old destination presented by path should have "wasActive" as false
        let destinationsCount = appFlow.activeDestinations.count
        if let oldDestination = appFlow.activeDestinations[destinationsCount-2] as? ColorDetailDestination {
            XCTAssertTrue(oldDestination.didDisappear)
            XCTAssertFalse(oldDestination.isVisible)
            XCTAssertFalse(oldDestination.wasVisible)
        } else {
            XCTFail()
        }
        
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic))

        wait(timeout: 0.1)

        if let presentedDestination = appFlow.currentDestination as? ColorDetailDestination {
            XCTAssertTrue(presentedDestination.didAppear)
            XCTAssertTrue(presentedDestination.isVisible)
        } else {
            XCTFail()
        }
        
        // single addition should have "wasActive" as true
        if let oldDestination = appFlow.activeDestinations[appFlow.activeDestinations.count-2] as? ColorDetailDestination {
            XCTAssertTrue(oldDestination.didDisappear)
            XCTAssertFalse(oldDestination.isVisible)
            XCTAssertTrue(oldDestination.wasVisible)
        } else {
            XCTFail()
        }
        
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(color: .yellow, name: "yellow")), assistantType: .basic))
        
        wait(timeout: 0.1)

        if let presentedDestination = appFlow.currentDestination as? ColorDetailDestination {
            XCTAssertTrue(presentedDestination.didAppear)
            XCTAssertTrue(presentedDestination.isVisible)
        } else {
            XCTFail()
        }
    }
    
    func test_navbar_move_back_from_detail_to_parent_VC() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
                
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorsList, presentationType: .navigationStack(type: .present), assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController)
        appFlow.start()
        
        wait(timeout: 0.1)
        
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable, let controller = currentDestination.currentController() as? TestColorsViewController, currentDestination.type == .colorsList {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.1)

            let indexpath = IndexPath(item: 1, section: 0)
            controller.selectCell(at: indexpath)
            
            wait(timeout: 0.7)
            
            if let detailDestination = appFlow.currentDestination as? any ControllerDestinationable, let detailController = try? XCTUnwrap(detailDestination.currentController() as? ColorDetailViewController, "couldn't find color detail vc") {
                detailController.prepareForFirstAppearance()

                wait(timeout: 0.3)
                            
                let goBackAction = PresentationConfiguration(presentationType: .navigationStack(type: .goBack), actionType: .systemNavigation, assistantType: .basic)
                goBackAction.currentDestinationID = detailDestination.id
                appFlow.presentDestination(configuration: goBackAction)

                if let newDestination = appFlow.activeDestinations.last as? any ControllerDestinationable & DestinationTypeable {
                    if let newController = try? XCTUnwrap(newDestination.currentController() as? TestColorsViewController, "couldn't find colors vc") {
                        newController.prepareForFirstAppearance()
                        wait(timeout: 0.3)
                        XCTAssert(newDestination.type == .colorsList, "expected current type list, but got \(newDestination.type) instead")
                        
                        XCTAssertTrue(type(of: newController) == TestColorsViewController.self, "expected current controller to be ColorsVC, got \(type(of: newController))")
                    }
                } else {
                    XCTFail("no new controller found")
                }

            } else {
                XCTFail("no new controller found")
            }
            

            
        } else {
            XCTFail("no current destination, expected .colorsList")
        }
    }
    
    func test_tabbar_move_to_detail_VC() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        let appFlow = testDestinations.buildAppFlow(startingDestination: startingDestination, navigationController: baseController, startingTabs: startingTabs)
        appFlow.start()
        
        wait(timeout: 0.1)
        
        moveToDetailView(startingType: startingType, appFlow: appFlow)
    }
    
    func test_tabbar_load_in_other_tab() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .navigationStack(type: .present), assistantType: .basic)

        let detailColor = ColorViewModel(colorID: UUID(), color: .red, name: "red")
        let modelToPass = ColorViewModel(colorID: UUID(), color: .purple, name: "purple")
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: detailColor), assistantType: .basic)
        let showInOtherTabAction = PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .home), contentType: .color(model: modelToPass), assistantType: .basic)

        let colorsListRetrieveAction = InteractorConfiguration<TestColorsDestination.InteractorType, TestColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(TestColorsInteractorAssistant(actionType: .retrieve)))
        let colorsListProvider = TestColorsListProvider(presentationsData: [TestColorsDestination.UserInteractions.color(model: nil): colorSelection], interactorsData: [.retrieveInitialColors: colorsListRetrieveAction])
        
        let colorDetailProvider = ColorDetailProvider(presentationsData: [ColorDetailDestination.UserInteractions.colorDetailButton(model: nil): showInOtherTabAction])
        let homeProvider = HomeProvider()
        let tabBarProvider = TestTabBarProvider()
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            startingType: tabBarProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
        
        wait(timeout: 0.1)
        
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable, let controller = currentDestination.currentController() as? TestColorsViewController {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.1)

            let indexpath = IndexPath(item: 1, section: 0)
            controller.selectCell(at: indexpath)
            
            wait(timeout: 0.7)

            if let newDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable {
                XCTAssert(newDestination.type == .colorDetail, "expected current type detail, but got \(newDestination.type) instead")
                

                wait(timeout: 0.7)
                
                if let newDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable {
                    if let newController = try? XCTUnwrap(newDestination.currentController() as? ColorDetailViewController, "couldn't find colorDetail") {
     
                        newController.prepareForFirstAppearance()
                        wait(timeout: 0.7)

                        newController.handleDetailTap()
                        wait(timeout: 1.0)

                        if let tabDestination = appFlow.findTabBarInViewHierarchy(currentDestination: newDestination), let tabController = try? XCTUnwrap(tabDestination.currentController() as? AppTabBarController, "couldn't find tab controller") {
    

                            XCTAssert(tabController.selectedIndex == tabController.tabIndex(for: AppTabType.home), "expected home tab selected, but found \(tabController.selectedIndex)")
                            XCTAssert(tabController.currentController(for: AppTabType.home) is ColorDetailViewController, "expected ColorDetailVC for home tab, found \(String(describing: tabController.destination().destinationIDsForTabs[AppTabType.home]))")
                            
                            if let detailController = try? XCTUnwrap(tabController.currentController(for: AppTabType.home) as? ColorDetailViewController, "couldn't find tab detail controller") {
                                XCTAssert(detailController.colorModel == modelToPass, "expected \(modelToPass), got \(String(describing: detailController.colorModel))")
                            }

                        }
                        
                    }
                }
                

            } else {
                XCTFail("no tapped model found")
            }
        } else {
            XCTFail("expected \(startingType) to be TestColorsViewController, found \(String(describing: appFlow.currentDestination?.type)) instead")
        }
    }
    
    
    func test_switch_tab() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)

        let colorsListProvider = TestColorsListProvider()
        let colorDetailProvider = ColorDetailProvider()
        let homeProvider = HomeProvider()
        let tabBarProvider = TestTabBarProvider()
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            startingType: tabBarProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
        
        wait(timeout: 0.3)
        
        // switch tab to Home
        appFlow.presentDestination(configuration: PresentationConfiguration(presentationType: .tabBar(tab: .home), assistantType: .basic))
        
        XCTAssertEqual(appFlow.currentDestination?.type, .home)
        
    }
    
    
    func test_replace_destination_in_tab_controller() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)

        let colorsListProvider = TestColorsListProvider()
        let colorDetailProvider = ColorDetailProvider()
        let homeProvider = HomeProvider()
        let tabBarProvider = TestTabBarProvider()
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            startingType: tabBarProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
        
        wait(timeout: 0.3)
        
        // switch tab to Home
        appFlow.presentDestination(configuration: PresentationConfiguration(presentationType: .tabBar(tab: .home), assistantType: .basic))
                
        wait(timeout: 0.3)

        
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic))
              
        wait(timeout: 0.5)
        
        XCTAssertEqual(appFlow.activeDestinations.count(where: { $0.type == .colorDetail }), 1)
        XCTAssertEqual(appFlow.activeDestinations.count(where: { $0.type == .home }), 0)
        
    }
    
    
    func test_replace_destination_in_splitview_controller() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .splitView, presentationType: .addToCurrent, assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        let startProvider = StartProvider()
        let colorsListProvider = TestColorsListProvider()
        let colorDetailProvider = ColorDetailProvider()
        let homeProvider = HomeProvider()
        let splitViewProvider = SplitViewProvider(initialContent: [.primary: .colorsList, .secondary: .colorDetail])
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .splitView: splitViewProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
                
        // replace Destination in detail column
        appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .splitView(column: SplitViewColumn(uiKit: .secondary)), contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic))
                            
        // SplitView started with one colorDetail, so presenting a new colorDetail in that column should add another to the nav controller
        XCTAssertEqual(appFlow.activeDestinations.count(where: { $0.type == .colorDetail }), 2)
        
    }
    
    
    func test_replace_destination_in_navigation_stack() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .navigationStack(type: .present), assistantType: .basic)

        let replaceAction = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, assistantType: .basic)

        let colorsListRetrieveAction = InteractorConfiguration<TestColorsDestination.InteractorType, TestColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(TestColorsInteractorAssistant(actionType: .retrieve)))
        let colorsListProvider = TestColorsListProvider(presentationsData: [TestColorsDestination.UserInteractions.color(model: nil): replaceAction], interactorsData: [.retrieveInitialColors: colorsListRetrieveAction])
        
        let colorDetailProvider = ColorDetailProvider()
        let homeProvider = HomeProvider()
        let tabBarProvider = TestTabBarProvider()
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            startingType: tabBarProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
        
        wait(timeout: 0.1)
        
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable, let controller = currentDestination.currentController() as? TestColorsViewController {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.1)

            let indexpath = IndexPath(item: 1, section: 0)
            controller.selectCell(at: indexpath)
            
            wait(timeout: 0.7)

            if let newDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable {
                XCTAssert(newDestination.type == .colorDetail, "expected current type detail, but got \(newDestination.type) instead")
                
                wait(timeout: 0.7)
                
                if let newDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable {
                    if let newController = try? XCTUnwrap(newDestination.currentController() as? ColorDetailViewController, "couldn't find colorDetail") {
                        
                        newController.prepareForFirstAppearance()
                        wait(timeout: 0.7)
                        
                        newController.handleDetailTap()
                        wait(timeout: 1.0)
                        
                        let detailCount = appFlow.activeDestinations.count(where: { $0.type == .colorDetail })
                        XCTAssertEqual(detailCount, 1, "Expected activeDestinationsn to contain one instance of type .colorDetail, but found \(detailCount)")
                        
                        // The remaining .colorDetail Destination should be the new Destination, not the old one
                        let detail = appFlow.activeDestinations.first(where: { $0.type == .colorDetail })
                        XCTAssertEqual(detail?.id, newDestination.id)
                        
                    }
                }
                

            } else {
                XCTFail("no tapped model found")
            }
        } else {
            XCTFail("expected \(startingType) to be TestColorsViewController, found \(String(describing: appFlow.currentDestination?.type)) instead")
        }
    }
    
    
    func test_move_back_in_splitview_controller() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .splitView, presentationType: .addToCurrent, assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        let startProvider = StartProvider()
        let colorsListProvider = TestColorsListProvider()
        let colorDetailProvider = ColorDetailProvider()
        let homeProvider = HomeProvider()
        let splitViewProvider = SplitViewProvider(initialContent: [.primary: .colorsList, .secondary: .colorDetail])
        
        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .splitView: splitViewProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")
        
        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
        
        guard let currentDestination = appFlow.currentDestination as? any ControllerDestinationable, let splitView = appFlow.findSplitViewInViewHierarchy(currentDestination: currentDestination) else {
            XCTFail("SplitView was not presented")
            return
        }

        let home = appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .home, presentationType: .splitView(column: SplitViewColumn(uiKit: .secondary)), assistantType: .basic))
        wait(timeout: 0.3)


        guard let newDestination = appFlow.presentDestination(configuration: PresentationConfiguration(destinationType: .colorDetail, presentationType: .splitView(column: SplitViewColumn(uiKit: .secondary)), contentType: .color(model: ColorViewModel(color: .green, name: "green")), assistantType: .basic)) else {
            XCTFail("Destination was not presented")
            return
        }
        wait(timeout: 0.3)

        let secondaryDestination = splitView.currentDestination(for: .secondary)
        XCTAssertEqual(secondaryDestination?.type, .colorDetail)
        XCTAssertEqual(splitView.groupInternalState.childDestinations.count, 4)
    
                                    
        newDestination.currentController()?.performSystemNavigationBack()
        wait(timeout: 0.7)

        // we moved back one in the navigation stack so there should only be 3 group children now
        XCTAssertEqual(splitView.groupInternalState.childDestinations.count, 3)

        // the current child of the SplitViewDestination should now be the home Destination
        let afterBackDestination = splitView.currentChildDestination()
        
        print("current children \(splitView.groupInternalState.childDestinations.map { $0.type })")

        XCTAssertEqual(afterBackDestination?.id, home?.id, "Expected currentChildDestination to be the previous Destination (home), but found \(String(describing: afterBackDestination?.type))")

        
    }
    
    func test_sheet_presentation() {
        guard let sceneDelegate else {
            XCTFail("No scene delegate present")
            return
        }
        
        let modelToPass = ColorViewModel(colorID: UUID(), color: .purple, name: "purple")
        let detailColor = ColorViewModel(colorID: UUID(), color: .red, name: "red")

        let startingType: RouteDestinationType = .colorDetail
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, contentType: .color(model: detailColor), assistantType: .basic)

        let sheetButtonInteraction = PresentationConfiguration(destinationType: .colorDetail, presentationType: .sheet(type: .present), contentType: .color(model: modelToPass), assistantType: .custom(ColorDetailActionAssistant()))

        let colorDetailProvider = ColorDetailProvider(presentationsData: [ColorDetailDestination.UserInteractions.colorDetailButton(model: nil): sheetButtonInteraction])

        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .colorDetail: colorDetailProvider
        ]
        
        let baseController = try? XCTUnwrap(sceneDelegate.rootController as? any ControllerDestinationInterfacing, "couldn't find base controller")

        let appFlow = ControllerFlow(destinationProviders: providers, startingDestination: startingDestination)
        if let root = baseController {
            appFlow.assignBaseController(root)
        }
        appFlow.start()
                
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable, let controller = currentDestination.currentController() as? ColorDetailViewController, currentDestination.type == startingType {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.3)
            controller.handleDetailTap()
            wait(timeout: 0.7)

            if let presentedDetailDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable {
                wait(timeout: 0.1)
                
                XCTAssert(presentedDetailDestination.type == .colorDetail, "expected current type detail, but got \(presentedDetailDestination.type) instead")
     
                if let newController = try? XCTUnwrap(presentedDetailDestination.currentController() as? ColorDetailViewController, "couldn't find colorDetail") {
                    newController.prepareForFirstAppearance()
                    wait(timeout: 0.3)
                    
                    XCTAssert(newController.colorModel == modelToPass, "expected \(modelToPass), got \(String(describing: newController.colorModel))")
                    
                    // verify that the new controller is being presented in a sheet
                    XCTAssert((newController.presentingViewController != nil || newController.isBeingPresented), "Expected VC to be presented in a sheet, newController parent \(String(describing: newController.parent))")

                }
                
                
            } else {
                XCTFail("no tapped model found")
            }
        } else {
            XCTFail("expected \(startingType), found \(String(describing: appFlow.currentDestination?.type)) instead")
        }
        
    }
}

extension AppFlowTests {
    
    func moveToDetailView(startingType: RouteDestinationType, appFlow: ControllerFlow<DestinationType, TabType, ContentType>) {
        
        if let currentDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable, let controller = currentDestination.currentController() as? TestColorsViewController {
            controller.prepareForFirstAppearance()
            wait(timeout: 0.1)

            let indexpath = IndexPath(item: 1, section: 0)
            let modelToTap = controller.model(for: indexpath)
            controller.selectCell(at: indexpath)
            
            if let modelToTap = modelToTap, let newDestination = appFlow.currentDestination as? any ControllerDestinationable & DestinationTypeable {
                XCTAssert(newDestination.type == .colorDetail, "expected current type detail, but got \(newDestination.type) instead")
                
                XCTAssert(newDestination.parentDestinationID() == currentDestination.id, "expected parent UUID to equal Colors list, got \(String(describing: newDestination.parentDestinationID()))")
                
                if let newController = newDestination.currentController() as? ColorDetailViewController {
                    XCTAssert(newController.colorModel == modelToTap, "expected same color model, got \(String(describing: newController.colorModel))")
                }
            } else {
                XCTFail("no tapped model found")
            }
        } else {
            XCTFail("expected \(startingType), found \(String(describing: appFlow.currentDestination?.type)) instead")
        }
    }
}
