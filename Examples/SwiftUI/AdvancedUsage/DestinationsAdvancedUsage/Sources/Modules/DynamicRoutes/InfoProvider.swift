//
//  InfoProvider.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct InfoProvider: ViewDestinationProviding, DestinationTypes {

    typealias EventType = InfoView.Events
    typealias Destination = ViewDestination<InfoView, EventType, DestinationType, ContentType, TabType, InteractorType>

    var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    var interactorsData: [EventType: any InteractorConfiguring<InteractorType>] = [:]

    func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .info, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = InfoView(destination: destination)
        destination.assignAssociatedView(view: view)

        return destination
    }
}
