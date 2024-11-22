//
//  BaseViewController.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations


enum GeneralAppInteractions: UserInteractionTypeable {
    var rawValue: String {
        return ""
    }
}

public enum AppInteractorType: InteractorTypeable {
    case test
}

final class BaseViewController: UIViewController, ControllerDestinationInterfacing, AppDestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias UserInteractionType = UserInteractions
    typealias Destination = ControllerDestination<UserInteractionType, BaseViewController, PresentationConfiguration, InteractorType>
        
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
                
        let startPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .start, presentationType: .replaceCurrent, assistantType: .basic),
            PresentationConfiguration(destinationType: .splitView, presentationType: .addToCurrent, assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        let colorSelection = PresentationConfiguration(destinationType: .colorDetail,
                                                       presentationType: .splitView(column: SplitViewColumn(uiKit: .secondary)),
                                                       assistantType: .custom(ChooseColorFromListActionAssistant()))

 
        let startProvider = StartProvider()
        let splitViewProvider = SplitViewProvider(initialContent: [.primary: .colorsList, .secondary: .colorDetail])
        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        let colorDetailProvider = ColorDetailProvider()


        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .splitView: splitViewProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider
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

