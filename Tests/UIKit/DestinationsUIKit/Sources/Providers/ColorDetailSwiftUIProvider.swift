//
//  ColorDetailProvider.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ColorDetailSwiftUIProvider: ViewDestinationProviding, DestinationTypes {

    public typealias Destination = ColorDetailView.Destination
    typealias EventType = Destination.EventType

    public var presentationsData: [Destination.EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ViewFlowable<DestinationType, AppContentType, TabType>) -> Destination? {

        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }

        let destination = Destination(destinationType: .colorDetailSwiftUI, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = ColorDetailView(destination: destination, model: colorModel)
        destination.assignAssociatedView(view: view)

        return destination

    }

}
