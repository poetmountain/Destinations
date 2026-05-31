//
//  SheetProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct SheetProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = SheetViewController.Destination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
   
    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        let destination = Destination(destinationType: .sheet, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let contentController = SheetContentViewController(destination: destination, content: configuration.contentType)
        let controller = SheetViewController(destination: destination, rootController: contentController)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
