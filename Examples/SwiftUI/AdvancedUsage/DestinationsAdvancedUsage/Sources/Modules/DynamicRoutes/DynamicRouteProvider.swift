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

    typealias Destination = DynamicRouteView.Destination
    typealias PresentationConfiguration = DestinationPresentation<Destination.DestinationType, Destination.ContentType, Destination.TabType>

    var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    var interactorsData: [Destination.EventType: any InteractorConfiguring<Destination.InteractorType>] = [:]

    init() {
        // The destinationType here acts as a default. The DynamicRouteAssistant
        // overrides it at runtime with the route passed via the content.
        let navigatePresentation = PresentationConfiguration(
            destinationType: .welcome,
            presentationType: .navigationStack(type: .present),
            assistantType: .custom(DynamicRouteAssistant<Destination.EventType>())
        )

        presentationsData = [.navigate: navigatePresentation]
    }

    func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, Destination.DestinationType, Destination.ContentType, Destination.TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, Destination.DestinationType, Destination.ContentType, Destination.TabType>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<Destination.DestinationType, Destination.ContentType, Destination.TabType>) -> Destination? {

        let destination = Destination(destinationType: .dynamic, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = DynamicRouteState()
        let view = DynamicRouteView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        return destination
    }
}
