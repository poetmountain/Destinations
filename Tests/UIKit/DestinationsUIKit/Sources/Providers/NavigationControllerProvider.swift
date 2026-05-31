//
//  NavigationControllerProvider.swift
//  DestinationsUIKitExample
//
//  Created by Brett Walker on 2/15/26.
//

import Foundation
import Destinations

final class NavigationControllerProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = DefaultNavigationControllerDestination<EventType, DestinationType, AppContentType, TabType, InteractorType>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        let destination = Destination(destinationType: .navController, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let controller = DefaultNavigationController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
}
