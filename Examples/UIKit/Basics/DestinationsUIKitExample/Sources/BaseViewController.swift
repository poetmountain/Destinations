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
    
    typealias UserInteractionType = UserInteractions
    typealias Destination = ControllerDestination<BaseViewController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>
        
    var destinationState: DestinationInterfaceState<Destination>
    
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
        
        let startPath: [DestinationPresentation<DestinationType, AppContentType, TabType>] = [
            DestinationPresentation<DestinationType, AppContentType, TabType>(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            DestinationPresentation<DestinationType, AppContentType, TabType>(destinationType: tabsType, presentationType: .navigationStack(type: .present), assistantType: .basic)
        ]
        let startingDestination = DestinationPresentation<DestinationType, AppContentType, TabType>(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        let homepath: [DestinationPresentation<DestinationType, AppContentType, TabType>] = [
            DestinationPresentation<DestinationType, AppContentType, TabType>(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            DestinationPresentation<DestinationType, AppContentType, TabType>(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .systemGreen, name: "green")), assistantType: .basic)
        ]
        let homePathPresent = DestinationPresentation<DestinationType, AppContentType, TabType>(presentationType: .destinationPath(path: homepath), assistantType: .basic)
        let homeProvider = HomeProvider(presentationsData: [.pathPresent: homePathPresent])
        
        let startProvider = StartProvider()
        let colorsListProvider = ColorsListProvider()
        let colorDetailProvider = ColorDetailProvider()
        let sheetViewProvider = SheetProvider()
        let tabBarProvider = TabBarProvider()
        
        let viewSetup: SwiftUIContainerProvider<ColorView>.SwiftUIViewSetupClosure = { (destination: SwiftUIContainerDestination<ColorView, ColorView.UserInteractionType, DestinationType, ContentType, TabType, InteractorType>, content: ContentType?) in
            var colorModel: ColorViewModel?
            if let content = content, case let .color(model) = content {
                colorModel = model
            } else {
                colorModel = ColorViewModel(color: .systemIndigo, name: "Indigo")
            }
            
            return ColorView(model: colorModel, parentDestination: destination)
        }
        
        let changeSwiftUIColor = DestinationPresentation<DestinationType, AppContentType, TabType>(destinationType: .swiftUI, presentationType: .replaceCurrent, assistantType: .custom(ChangeColorActionAssistant()))
        let swiftUIProvider = SwiftUIContainerProvider<ColorView>(presentationsData: [.changeColor: changeSwiftUIColor], viewSetup: viewSetup)

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
        appFlow?.assignBaseController(self)
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
    typealias Destination = NavigationControllerDestination<StartViewController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>
        
    var destinationState: DestinationInterfaceState<Destination>
        
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
