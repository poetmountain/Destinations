//
//  ColorsListProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ColorsListProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias Destination = ColorsListDestination
    
    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init() {
        // presentation actions
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), assistantType: .custom(ChooseColorFromListActionAssistant()))
        
        // interactor actions
        let paginateAction = InteractorConfiguration<ColorsListDestination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate, assistantType: .custom(ColorsInteractorAssistant(actionType: .paginate)))
        let colorsListRetrieveAction = InteractorConfiguration<ColorsListDestination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(ColorsInteractorAssistant(actionType: .retrieve)))
        
        presentationsData = [.color(model: nil): colorSelection]
        interactorsData = [.moreButton: paginateAction, .retrieveInitialColors: colorsListRetrieveAction]
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
        
        let destination = ColorsListDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let controller = ColorsViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        let datasource = ColorsDatasource()
        destination.setupInteractor(interactor: datasource, for: .colors)
                
         return destination
        
    }
    


}
