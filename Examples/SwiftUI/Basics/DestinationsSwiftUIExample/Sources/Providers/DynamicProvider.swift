//
//  DynamicProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class DynamicProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias Destination = DynamicDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init(presentationsData: [Destination.UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {
        
        guard let contentType = configuration.contentType, case .dynamicView(view: let customView) = contentType else { return nil }
        
        let destination = DynamicDestination(navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let dynamicView = DynamicView(destination: destination) {
            AnyView(customView)
        }
        destination.assignAssociatedView(view: dynamicView)

        return destination
        
    }
    
}
