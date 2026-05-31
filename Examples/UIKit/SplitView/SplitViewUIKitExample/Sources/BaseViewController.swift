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


enum GeneralAppEvents: EventTypeable {
    var rawValue: String {
        return ""
    }
}

public enum AppInteractorType: InteractorTypeable {
    case test
}

final class BaseViewController: UIViewController, ControllerDestinationInterfacing, AppDestinationTypes {
        
    enum Events: EventTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias EventType = Events
    typealias Destination = ControllerDestination<BaseViewController, EventType, DestinationType, ContentType, TabType, InteractorType>
        
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
            PresentationConfiguration(destinationType: .splitView, presentationType: .replaceCurrent, assistantType: .basic)
        ]
        let startingDestination = PresentationConfiguration(presentationType: .destinationPath(path: startPath), assistantType: .basic)

        let colorSelection = PresentationConfiguration(destinationType: .colorDetail,
                                                       presentationType: .splitView(column: SplitViewColumn(uiKit: .secondary)),
                                                       assistantType: .custom(ChooseColorFromListActionAssistant()))

 
        let startProvider = StartProvider()
        let splitViewProvider = SplitViewProvider(initialContent: [.primary: .colorsList, .secondary: .colorNav])
        
        let colorsListRetrieveAction = InteractorConfiguration<ColorsViewController.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .basicAsync)
        
        let colorsListProvider = ColorsListProvider(presentationsData: [.color: colorSelection], interactorsData: [.retrieveInitialColors: colorsListRetrieveAction])
        let colorContainerProvider = ColorDetailContainerProvider()

        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .splitView: splitViewProvider,
            .colorsList: colorsListProvider,
            .colorNav: colorContainerProvider
        ]
        
        return ControllerFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination, routesToIgnore: [.colorDetail, .swiftUI])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appFlow = buildAppFlow()
        appFlow?.assignBaseController(self)
        appFlow?.start()

    }


}

