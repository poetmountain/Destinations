//
//  HomeProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct HomeProvider: ControllerDestinationProviding, DestinationTypes {
    
    typealias UserInteractionType = HomeUserInteractions
    public typealias Destination = ControllerDestination<HomeViewController, HomeUserInteractions, DestinationType, ContentType, TabType, InteractorType>

    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        let destination = ControllerDestination<HomeViewController, HomeUserInteractions, DestinationType, ContentType, TabType, HomeViewController.InteractorType>(destinationType: .home, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let controller = HomeViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
}

