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

final class ColorDetailProvider: ViewDestinationProviding, AppDestinationTypes {

    public typealias Destination = ColorDetailView.Destination
    public typealias EventType = ColorDetailView.EventType
    public typealias InteractorType = Destination.InteractorType

    public var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<InteractorType>] = [:]

    init(presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>]? = nil, interactorsData: [EventType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }

        self.presentationsData[.none] = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .addToCurrent, assistantType: .basic)
    }

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }

        let destination = Destination(destinationType: .colorDetail, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = ColorDetailState(colorModel: colorModel)
        let view = ColorDetailView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        return destination

    }

}
