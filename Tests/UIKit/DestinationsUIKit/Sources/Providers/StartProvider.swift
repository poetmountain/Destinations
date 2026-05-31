//
//  StartProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct StartProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = NavigationControllerDestination<StartViewController, StartViewController.Events, DestinationType, AppContentType, TabType, StartViewController.InteractorType>

    public var presentationsData: [Destination.EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, AppContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        let destination = NavigationControllerDestination<StartViewController, StartViewController.Events, DestinationType, AppContentType, TabType, StartViewController.InteractorType>(destinationType: .start, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let controller = StartViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
