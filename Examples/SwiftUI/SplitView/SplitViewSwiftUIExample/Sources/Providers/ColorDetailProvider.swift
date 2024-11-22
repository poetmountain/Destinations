//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class ColorDetailProvider: ViewDestinationProviding, AppDestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = ColorDetailDestination.UserInteractions
    public typealias InteractorType = ColorDetailDestination.InteractorType
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
    
    init(presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> (any ViewDestinationable)? {
        
        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }
        
        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
        
        let destination = ColorDetailDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)


        let view = ColorDetailView(destination: destination, model: colorModel)
        destination.assignAssociatedView(view: view)

        return destination
        
    }
    
}
