//
//  ColorsListProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorsListProvider: ControllerDestinationProviding, DestinationTypes  {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias UserInteractionType = ColorsListDestination.UserInteractions
    public typealias InteractorType = ColorsListDestination.InteractorType
    
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
        
        let destination = ColorsListDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let controller = ColorsViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        let datasource = ColorsDatasource()
        destination.setupInteractor(interactor: datasource, for: .colors)
        
        for (interactionType, setupModel) in interactorsData {
            switch setupModel.interactorType {
                case .colors:
                    if let setupModel = setupModel as? InteractorConfiguration<InteractorType, ColorsDatasource> {
                        let assistant = ColorsInteractorAssistant(actionType: setupModel.actionType)
                        destination.assignInteractorAssistant(assistant: assistant, for: interactionType)
                    }
            }
        }
        
         return destination
        
    }
    
    

}
