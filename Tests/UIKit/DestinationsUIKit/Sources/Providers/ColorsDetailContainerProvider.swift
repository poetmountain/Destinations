//
//  ColorsListContainerProvider.swift
//  SplitViewUIKitExample
//
//  Created by Brett Walker on 2/1/25.
//

import Foundation
import Destinations

struct ColorsDetailContainerProvider: ControllerDestinationProviding, DestinationTypes {

    typealias EventType = ColorNavProvider.EventType
    public typealias Destination = SwiftUIContainerDestination<ColorNavView, EventType, DestinationType, ContentType, TabType, InteractorType>

    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<ColorNavView, EventType, DestinationType, ContentType, TabType, InteractorType>, _ content: ContentType?) -> ColorNavView
    
    var destinationType: DestinationType = .colorDetailSwiftUI
    
    public var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination? {
 
        let parentDestination = SwiftUIContainerDestination<ColorNavView, EventType, DestinationType, ContentType, TabType, InteractorType>(destinationType: .swiftUI, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let colorNavProvider = ColorNavProvider(presentationsData: presentationsData, containerDestination: parentDestination)
        let colorDetailProvider = ColorDetailSwiftUIProvider()
        
        
        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorNav: colorNavProvider,
            .colorDetailSwiftUI: colorDetailProvider
        ]
        
        let startingPath: [DestinationPresentation<DestinationType, AppContentType, TabType>] = [
            DestinationPresentation<DestinationType, AppContentType, TabType>(destinationType: .colorNav, presentationType: .replaceCurrent, contentType: configuration.contentType, assistantType: .basic)
        ]
        
        let startingPresentation = DestinationPresentation<DestinationType, AppContentType, TabType>(presentationType: .destinationPath(path: startingPath), contentType: configuration.contentType, assistantType: .basic)
        
        let viewFlow = ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingPresentation, routesToIgnore: [.colorDetailSwiftUI, .swiftUI, .sheet, .home, .start, .colorsList, .colorDetail, .tabBar(tabs: [])])
        
        parentDestination.viewFlow = viewFlow
        viewFlow.start()

        
        if let destination = viewFlow.rootDestination as? ColorNavView.Destination, let view = destination.view {
            let adapter = SwiftUIAdapter<ColorNavView>(content: { view })
            adapter.hostingController.sizingOptions = [.intrinsicContentSize]
            adapter.hostingController.safeAreaRegions = []
            
            let containerController = SwiftUIContainerController<ColorNavView>(adapter: adapter)
            parentDestination.assignAssociatedController(controller: containerController)
        }
        
        return parentDestination
        
    }
    
    

}
