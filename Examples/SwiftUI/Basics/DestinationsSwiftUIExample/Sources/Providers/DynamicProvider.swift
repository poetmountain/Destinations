//
//  DynamicProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct DynamicProvider: ViewDestinationProviding, DestinationTypes {

    public typealias Destination = DynamicView<AnyView>.Destination

    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        guard let contentType = configuration.contentType, case .dynamicView(view: let customView) = contentType else { return nil }

        let destination = Destination(destinationType: .dynamic, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let dynamicView = DynamicView(destination: destination) {
            AnyView(customView)
        }
        destination.assignAssociatedView(view: dynamicView)

        return destination

    }

}
