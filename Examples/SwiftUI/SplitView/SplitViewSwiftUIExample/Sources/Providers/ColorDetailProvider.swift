//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorDetailProvider: ViewDestinationProviding, AppDestinationTypes {
    
    public typealias Destination = ColorDetailView.Destination

    public var presentationsData: [Destination.EventType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init() {
        presentationsData[.none] = PresentationConfiguration(presentationType: .addToCurrent, assistantType: .basic)
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }
        
        let state = ColorDetailState(colorModel: colorModel)
        let destination = Destination(destinationType: .colorDetail, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)


        let view = ColorDetailView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        return destination
        
    }
    
}
