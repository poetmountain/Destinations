//
//  DynamicRouteProvider.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct DynamicRouteProvider: ViewDestinationProviding {

    typealias DestinationType = Destination.DestinationType
    typealias TabType = Destination.TabType
    typealias ContentType = Destination.ContentType

    typealias Destination = DynamicRouteDestination
    typealias PresentationConfiguration = DestinationPresentation<Destination.DestinationType, Destination.ContentType, Destination.TabType>

    var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    var interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>] = [:]

    init() {
        // The destinationType here acts as a default. The DynamicRouteAssistant
        // overrides it at runtime with the route passed via the content.
        let navigatePresentation = PresentationConfiguration(
            destinationType: .welcome,
            presentationType: .navigationStack(type: .present),
            assistantType: .custom(DynamicRouteAssistant<Destination.UserInteractionType>())
        )

        presentationsData = [.navigate: navigatePresentation]
    }

    func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, Destination.DestinationType, Destination.ContentType, Destination.TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, Destination.DestinationType, Destination.ContentType, Destination.TabType>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<Destination.DestinationType, Destination.ContentType, Destination.TabType>) -> Destination? {

        let destination = DynamicRouteDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = DynamicRouteView(destination: destination)
        destination.assignAssociatedView(view: view)

        return destination
    }
}
