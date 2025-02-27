//
//  BaseViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import SwiftUI
import Destinations

enum GeneralAppInteractions: UserInteractionTypeable {
    var rawValue: String {
        return ""
    }
}

public enum AppInteractorType: InteractorTypeable {
    case test
}

final class BaseViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias UserInteractionType = UserInteractions
    typealias Destination = ControllerDestination<UserInteractionType, BaseViewController, PresentationConfiguration, InteractorType>
        
    var destinationState: DestinationInterfaceState<Destination>

    let transitionAnimator = AnimationTransitionCoordinator()
    
    var appFlow: ControllerFlow<DestinationType, TabType, ContentType>?
    
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildAppFlow() -> ControllerFlow<DestinationType, TabType, ContentType> {
                
        let startingTabs: [AppTabType] = [.palettes, .home, .swiftUI]
        let tabsType: RouteDestinationType = .tabBar(tabs: startingTabs)
        
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: tabsType, presentationType: .navigationController(type: .present), assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        
        let homepath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), contentType: .color(model: ColorViewModel(color: .systemGreen, name: "green")), assistantType: .basic)
        ]
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), assistantType: .custom(ChooseColorFromListActionAssistant()))
        let homePathPresent = PresentationConfiguration(presentationType: .destinationPath(path: homepath), assistantType: .basic)
        
        let options = SheetPresentationOptions(uiKit: ControllerSheetPresentationOptions(presentationStyle: .formSheet, configurationClosure: { sheet in
            
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }))
        let sheetPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .sheet(type: .present, options: options), assistantType: .custom(ColorDetailActionAssistant()))
        let customOptions = SheetPresentationOptions(uiKit: ControllerSheetPresentationOptions(presentationStyle: .custom, transitionDelegate: transitionAnimator))
        let customSheetPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .sheet(type: .present, options: customOptions), assistantType: .custom(ColorDetailActionAssistant()))
        
        
        let customPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .custom(presentation: CustomPresentation<PresentationConfiguration>(uiKit: { (destinationToPresent, rootController, currentDestination, parentOfCurrentDestination, completionClosure) in
            guard let destinationToPresent else {
                completionClosure?(false)
                return
            }
                       
            completionClosure?(true)
            
        })), assistantType: .basic)
        
        let changeSwiftUIColor = PresentationConfiguration(destinationType: .swiftUI, presentationType: .replaceCurrent, assistantType: .custom(ChangeColorActionAssistant()))
              
        let startProvider = StartProvider()
        
        let colorsListRetrieveAction = InteractorConfiguration<ColorsListDestination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(ColorsInteractorAssistant(actionType: .retrieve)))
        
        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection], interactorsData: [.moreButton: InteractorConfiguration<ColorsListDestination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate, assistantType: .custom(ColorsInteractorAssistant(actionType: .paginate))), .retrieveInitialColors: colorsListRetrieveAction])
        
        let colorDetailProvider = ColorDetailProvider(presentationsData: [.colorDetailButton(model: nil): sheetPresent, .customDetailButton(model: nil): customSheetPresent])
        let homeProvider = HomeProvider(presentationsData: [.pathPresent: homePathPresent])
        let sheetViewProvider = SheetProvider()
        let tabBarProvider = TabBarProvider()
        
        let viewSetup: SwiftUIContainerProvider<ColorView>.SwiftUIViewSetupClosure = { (destination: SwiftUIContainerDestination<ColorView, PresentationConfiguration>, content: ContentType?) in
            var colorModel: ColorViewModel?
            if let content = content, case let .color(model) = content {
                colorModel = model
            } else {
                colorModel = ColorViewModel(color: .systemIndigo, name: "Indigo")
            }
            
            return ColorView(model: colorModel, parentDestination: destination)
        }
        let swiftUIProvider = SwiftUIContainerProvider<ColorView>(viewSetup: viewSetup, presentationsData: [.changeColor: changeSwiftUIColor])

        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider,
            .sheet: sheetViewProvider,
            .swiftUI: swiftUIProvider,
            .tabBar(tabs: startingTabs): tabBarProvider
        ]
        
        return ControllerFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appFlow = buildAppFlow()
        appFlow?.assignRoot(rootController: self)
        appFlow?.start()

    }


}

final class StartViewController: UINavigationController, NavigationControllerDestinationInterfacing, DestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias UserInteractionType = UserInteractions
    typealias Destination = NavigationControllerDestination<UserInteractionType, StartViewController, PresentationConfiguration, InteractorType>
        
    var destinationState: DestinationInterfaceState<Destination>
        
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
