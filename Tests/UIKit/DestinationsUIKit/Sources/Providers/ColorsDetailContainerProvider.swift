//
//  ColorsListContainerProvider.swift
//  SplitViewUIKitExample
//
//  Created by Brett Walker on 2/1/25.
//

import Foundation
import Destinations

struct ColorsDetailContainerProvider: ControllerDestinationProviding, DestinationTypes  {
    
    public typealias Destination = SwiftUIContainerDestination<ColorNavView, PresentationConfiguration>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>

    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<ColorNavView, PresentationConfiguration>, _ content: ContentType?) -> ColorNavView
    
    var destinationType: DestinationType = .colorDetailSwiftUI
    
    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
 
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
