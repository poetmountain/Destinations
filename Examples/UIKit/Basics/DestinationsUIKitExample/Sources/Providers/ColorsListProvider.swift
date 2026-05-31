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
    public typealias Destination = ColorsViewController.Destination
    
    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init() {
        // presentation actions
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .custom(ChooseColorFromListActionAssistant()))
        
        // interactor actions
        let paginateAction = InteractorConfiguration<Destination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate, assistantType: .basicAsync)
        let colorsListRetrieveAction = InteractorConfiguration<Destination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .basicAsync)
        
        presentationsData = [.color: colorSelection]
        interactorsData = [.moreButton: paginateAction, .retrieveInitialColors: colorsListRetrieveAction]
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .colorsList, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = ColorsListState(destination: destination)
        destination.stateModel = state

        let controller = ColorsViewController(destination: destination, state: state)
        destination.assignAssociatedController(controller: controller)

        let datasource = ColorsDatasource()
        destination.assignInteractor(interactor: datasource, for: .colors)
                
         return destination
        
    }
    


}
