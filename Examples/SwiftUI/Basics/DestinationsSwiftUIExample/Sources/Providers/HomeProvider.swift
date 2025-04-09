//
//  HomeProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct HomeProvider: ViewDestinationProviding, DestinationTypes {
    
    typealias DestinationType = HomeView.DestinationType
    typealias ContentType = HomeView.ContentType
    typealias TabType = HomeView.TabType
    typealias UserInteractionType = HomeView.UserInteractions

    public typealias Destination =  ViewDestination<HomeView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>

    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destination = Destination(destinationType: .home, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = HomeView(destination: destination)
        destination.assignAssociatedView(view: view)

        return destination
        
    }
    
}
