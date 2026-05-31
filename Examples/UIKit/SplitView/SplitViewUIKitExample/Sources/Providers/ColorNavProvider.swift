//
//  ColorNavProvider.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

final class ColorNavProvider: ViewDestinationProviding, AppDestinationTypes {

    public typealias Destination = ColorNavView.Destination
    public typealias EventType = ColorNavView.EventType
    public typealias InteractorType = Destination.InteractorType

    public var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<InteractorType>] = [:]

    var containerDestination: SwiftUIContainerDestination<ColorNavView, EventType, DestinationType, ContentType, TabType, InteractorType>

    init(presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>]? = nil, interactorsData: [EventType: any InteractorConfiguring<InteractorType>]? = nil, containerDestination: SwiftUIContainerDestination<ColorNavView, EventType, DestinationType, ContentType, TabType, InteractorType>) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }

        self.containerDestination = containerDestination
    }

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .colorNav, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = ColorNavView(destination: destination, parentDestination: containerDestination)
        destination.assignAssociatedView(view: view)

        return destination

    }

}
