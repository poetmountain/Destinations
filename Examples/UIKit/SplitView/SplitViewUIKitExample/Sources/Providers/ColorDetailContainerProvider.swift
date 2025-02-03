//
//  ColorsListContainerProvider.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

final class ColorDetailContainerProvider: ControllerDestinationProviding, AppDestinationTypes  {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias UserInteractionType = ColorNavDestination.UserInteractions
    public typealias InteractorType = ColorNavDestination.InteractorType
    
    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<ColorNavView, PresentationConfiguration>, _ content: ContentType?) -> ColorNavView
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
        
    var destinationType: DestinationType = .colorDetail
    
    init(presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
        
    }
    
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> (any ControllerDestinationable)? {
        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
    
        let parentDestination = SwiftUIContainerDestination<ColorNavView, PresentationConfiguration>(destinationType: .swiftUI, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let colorNavProvider = ColorNavProvider(presentationsData: presentationsData, containerDestination: parentDestination)
        let colorDetailProvider = ColorDetailProvider()
        
        
        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorNav: colorNavProvider,
            .colorDetail: colorDetailProvider
        ]
        
        let startingPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorNav, presentationType: .replaceCurrent, contentType: configuration.contentType, assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .custom(ChooseColorFromListActionAssistant()))
        ]
        
        let startingPresentation = PresentationConfiguration(presentationType: .destinationPath(path: startingPath), contentType: configuration.contentType, assistantType: .basic)
        
        let viewFlow = ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingPresentation)
        
        parentDestination.viewFlow = viewFlow
        viewFlow.start()

        
        if let destination = viewFlow.rootDestination as? ColorNavDestination, let view = destination.view {
            let adapter = SwiftUIAdapter<ColorNavView>(content: { view })
            adapter.hostingController.sizingOptions = [.intrinsicContentSize]
            adapter.hostingController.safeAreaRegions = []
            
            let containerController = SwiftUIContainerController<ColorNavView>(adapter: adapter)
            parentDestination.assignAssociatedController(controller: containerController)
        }
        
        return parentDestination
        
    }
    
    

}
