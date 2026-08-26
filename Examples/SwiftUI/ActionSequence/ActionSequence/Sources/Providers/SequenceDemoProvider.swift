//
//  SequenceDemoProvider.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct SequenceDemoProvider: ViewDestinationProviding, DestinationTypes {

    public typealias Destination = SequenceDemoView.Destination
    public typealias EventType = SequenceDemoView.Events
    typealias SequenceStepType = SequenceDemoView.SequenceStepType

    var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    var interactorsData: [EventType: any InteractorConfiguring<InteractorType>] = [:]
    var preflightIgnoredEvents: [EventType] = [.retrieveAndSaveImages]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        let destination = Destination(destinationType: .sequenceDemo, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let state = SequenceDemoState(destination: destination)
        destination.stateModel = state

        let view = SequenceDemoView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        destination.assignInteractor(ImageRetrievalInteractor(), to: .imageRetrieval)
        destination.assignInteractor(SaveToDiskInteractor(), to: .imageSaver)
        destination.assignInteractor(ApplyImageFilterInteractor(), to: .imageFilter)

        return destination
    }
}
