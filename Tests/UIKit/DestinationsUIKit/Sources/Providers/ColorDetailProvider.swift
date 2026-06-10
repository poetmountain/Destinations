//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ColorDetailProvider: ControllerDestinationProviding, DestinationTypes {

    typealias EventType = ColorDetailViewController.EventType
    public typealias Destination = ColorDetailViewController.Destination

    public var presentationsData: [EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    init(presentationsData: [EventType: DestinationPresentation<DestinationType, AppContentType, TabType>]? = nil, interactorsData: [EventType : any InteractorConfiguring<Destination.InteractorType>]? = nil) {

        if let presentationsData {
            self.presentationsData = presentationsData

        } else {
            let modelToPass = ColorViewModel(colorID: UUID(), color: .purple, name: "purple")
            let sheetButtonInteraction = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .colorDetail, presentationType: .sheet(type: .present), contentType: .color(model: modelToPass), assistantType: .custom(ColorDetailActionAssistant()))
            self.presentationsData[.colorDetailButton(model: nil)] = sheetButtonInteraction

        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }

        let moveToNearestAction = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .colorDetail, presentationType: .moveToNearest, assistantType: .basic)

        self.presentationsData[.moveToNearest] = moveToNearestAction
    }

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {

        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }

        let destination = Destination(destinationType: .colorDetail, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = ColorDetailState(colorModel: colorModel)
        destination.stateModel = state
        let controller = ColorDetailViewController(destination: destination, state: state)
        destination.assignAssociatedController(controller: controller)

        return destination

    }

}
