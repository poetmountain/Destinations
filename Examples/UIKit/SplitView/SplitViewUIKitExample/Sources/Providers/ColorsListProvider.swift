//
//  ColorsListProvider.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorsListProvider: ControllerDestinationProviding, AppDestinationTypes  {

    public typealias Destination = ColorsViewController.Destination
    public typealias EventType = ColorsViewController.EventType
    public typealias InteractorType = ColorsViewController.InteractorType

    public var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<InteractorType>] = [:]

    init(presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>]? = nil, interactorsData: [EventType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }


    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .colorsList, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = ColorsListState(destination: destination)
        destination.stateModel = state

        let controller = ColorsViewController(destination: destination, state: state)
        destination.assignAssociatedController(controller: controller)


        let datasource = ColorsDatasource()
        destination.assignInteractor(interactor: datasource, for: .colors)

         return destination

    }


}
