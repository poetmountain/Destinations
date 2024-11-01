//
//  HomeProvider.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 10/24/24.
//

import Foundation
import Destinations

final class HomeProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = HomeUserInteractions
    public typealias InteractorType = HomeViewController.InteractorType
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
    
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
        
        let destination = ControllerDestination<HomeUserInteractions, HomeViewController, PresentationConfiguration, InteractorType>(destinationType: .home, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let controller = HomeViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}

