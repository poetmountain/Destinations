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

struct ColorNavProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias Destination = ColorNavDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    var containerDestination: SwiftUIContainerDestination<ColorNavView, ColorNavView.PresentationConfiguration>

    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {

        let destination = ColorNavDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = ColorNavView(destination: destination, parentDestination: containerDestination)
        destination.assignAssociatedView(view: view)
        
        return destination
        
    }
    
}
