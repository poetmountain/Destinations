//
//  ColorsListProvider.swift
///
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorsListProvider: ViewDestinationProviding, DestinationTypes {

    public typealias Destination = ColorsListView.Destination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    init(presentationsData: [Destination.EventType: PresentationConfiguration]? = nil) {

        if let presentationsData {
            self.presentationsData = presentationsData
        } else {
            let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .custom(ChooseColorFromListActionAssistant()))
            self.presentationsData = [.color(model: nil): colorSelection]

        }

        // interactor actions
        let colorsListRetrieveAction = InteractorConfiguration<ColorsListView.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(ColorsInteractorAssistant()))

        interactorsData = [.retrieveInitialColors: colorsListRetrieveAction]
    }

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .colorsList, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = ColorsListState(destination: destination)
        destination.stateModel = state
        let listView = ColorsListView(destination: destination, state: state)
        destination.assignAssociatedView(view: listView)

        let datasource = ColorsDatasource()
        destination.assignInteractor(interactor: datasource, for: .colors)

         return destination

    }


}
