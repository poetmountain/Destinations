//
//  CounterProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct CounterProvider: ViewDestinationProviding, DestinationTypes {

    public typealias Destination = CounterView.Destination

    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    init() {
        let startCountAction = InteractorConfiguration<Destination.InteractorType, CounterInteractor>(
            interactorType: .counter,
            actionType: .startCount,
            assistantType: .custom(CounterInteractorAssistant()))
        let stopCountAction = InteractorConfiguration<Destination.InteractorType, CounterInteractor>(
            interactorType: .counter,
            actionType: .stopCount,
            assistantType: .custom(CounterInteractorAssistant()))

        interactorsData = [.start: startCountAction, .stop: stopCountAction]
    }

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let state = CounterState()
        let destination = Destination(destinationType: .counter, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let counterView = CounterView(destination: destination, state: state)
        destination.assignAssociatedView(view: counterView)

        let interactor = CounterInteractor()
        destination.assignInteractor(interactor: interactor, for: .counter)

         return destination

    }



}
