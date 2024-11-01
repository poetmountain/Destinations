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
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = HomeView.UserInteractions
    public typealias InteractorType = HomeView.InteractorType
    
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
        guard let contentType = configuration.contentType, case .dynamicView(view: let customView) = contentType else { return nil }

        let navigationPresentations = buildSystemPresentations()
        
        let destination = DynamicDestination(navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let dynamicView = DynamicView(destination: destination) {
            AnyView(customView)
        }
        destination.assignAssociatedView(view: dynamicView)

        return destination
        
    }
    
}
