//
//  ColorsListProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorsListProvider: ViewDestinationProviding, AppDestinationTypes {
    
    public typealias Destination = ColorsListView.Destination

    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destination = Destination(destinationType: .colorsList, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = ColorsListState(destination: destination)
        destination.stateModel = state

        let listView = ColorsListView(destination: destination, state: state)
        destination.assignAssociatedView(view: listView)

        let datasource = ColorsDatasource()
        destination.assignInteractor(interactor: datasource, for: .colors)

         return destination
        
    }
    

}
