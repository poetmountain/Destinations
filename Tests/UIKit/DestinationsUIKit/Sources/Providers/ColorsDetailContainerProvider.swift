//
//  ColorsListContainerProvider.swift
//  SplitViewUIKitExample
//
//  Created by Brett Walker on 2/1/25.
//

import Foundation
import Destinations

final class ColorsDetailContainerProvider: ControllerDestinationProviding, DestinationTypes  {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias UserInteractionType = ColorNavDestination.UserInteractions
    public typealias InteractorType = ColorNavDestination.InteractorType
    
    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<ColorNavView, PresentationConfiguration>, _ content: ContentType?) -> ColorNavView
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
        
    var destinationType: DestinationType = .colorDetailSwiftUI
    
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
        let colorDetailProvider = ColorDetailSwiftUIProvider()
        
        
        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorNav: colorNavProvider,
            .colorDetailSwiftUI: colorDetailProvider
        ]
        
        let startingPath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorNav, presentationType: .replaceCurrent, contentType: configuration.contentType, assistantType: .basic)
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
