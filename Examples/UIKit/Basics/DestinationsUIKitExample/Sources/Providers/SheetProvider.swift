//
//  SheetProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

final class SheetProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = SheetDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
   
    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init(presentationsData: [Destination.UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
        
        let destination = SheetDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let contentController = SheetContentViewController(destination: destination, content: configuration.contentType)
        let controller = SheetViewController(destination: destination, rootController: contentController)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
