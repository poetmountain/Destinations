//
//  NavigationControllerProvider.swift
//  DestinationsUIKitExample
//
//  Created by Brett Walker on 2/15/26.
//

import Foundation
import Destinations

final class NavigationControllerProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = DefaultNavigationControllerDestination<UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        let destination = Destination(destinationType: .navController, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let controller = DefaultNavigationController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
}
