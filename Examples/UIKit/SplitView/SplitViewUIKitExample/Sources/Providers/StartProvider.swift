//
//  StartProvider.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class StartProvider: ControllerDestinationProviding, AppDestinationTypes {
    
    public typealias Destination = NavigationControllerDestination<StartViewController, StartViewController.Events, StartViewController.DestinationType, StartViewController.ContentType, StartViewController.TabType, StartViewController.InteractorType>
    public typealias EventType = StartViewController.EventType
    public typealias InteractorType = StartViewController.InteractorType
    
    public var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<InteractorType>] = [:]
    
    init(presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>]? = nil, interactorsData: [EventType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destination = NavigationControllerDestination<StartViewController, StartViewController.Events, StartViewController.DestinationType, StartViewController.ContentType, StartViewController.TabType, StartViewController.InteractorType>(destinationType: .start, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let controller = StartViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
