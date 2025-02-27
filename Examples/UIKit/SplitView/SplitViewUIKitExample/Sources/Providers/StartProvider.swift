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
    
    public typealias Destination = NavigationControllerDestination<StartViewController.UserInteractions, StartViewController, StartViewController.PresentationConfiguration, StartViewController.InteractorType>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = StartViewController.UserInteractionType
    public typealias InteractorType = StartViewController.InteractorType
    
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
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
        
        let destination = NavigationControllerDestination<StartViewController.UserInteractions, StartViewController, StartViewController.PresentationConfiguration, StartViewController.InteractorType>(destinationType: .start, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let controller = StartViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
