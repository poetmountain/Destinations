//
//  ColorsListProvider.swift
///
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorsListProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias Destination = ColorsListDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {
        
        let destination = ColorsListDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let listView = ColorsListView(destination: destination)
        destination.assignAssociatedView(view: listView)

        let datasource = ColorsDatasource(with: ColorsPresenter())
        destination.assignInteractor(interactor: datasource, for: .colors)
        
         return destination
        
    }
    

}
