//
//  TabBarProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class TabBarProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias UserInteractionType = AppTabView.UserInteractions
    public typealias InteractorType = TabViewDestination<PresentationConfiguration, AppTabView>.InteractorType
    
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
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        guard case let RouteDestinationType.tabBar(tabs: tabs) = destinationType else { return nil }
        
        var tabTypes: [TabType] = []
        var typesForDestinations: [TabType: UUID] = [:]
        var tabDestinations: [any ViewDestinationable<PresentationConfiguration>] = []
        
        // create starting content for each tab
        for tabType in tabs {
            let tabContentType: RouteDestinationType
            switch tabType {
                case .palettes:
                    tabContentType = .colorsList
                case .home:
                    tabContentType = .home
            }
            let tabConfig = configuration
            tabConfig.destinationType = tabContentType
            
            
            if let destination = appFlow.buildDestination(for: tabConfig) {
                tabTypes.append(tabType)
                tabDestinations.append(destination)
                typesForDestinations[tabType] = destination.id
            }
        }
        
        let navigationPresentations = buildSystemPresentations()

        if let destination = TabViewDestination<PresentationConfiguration, AppTabView>(type: RouteDestinationType.tabBar(tabs: tabs), tabDestinations: tabDestinations, tabTypes: tabTypes, selectedTab: .palettes, navigationConfigurations: navigationPresentations) {
            
            let tabView = AppTabView(destination: destination)
            destination.assignAssociatedView(view: tabView)
            
            for tabDestination in tabDestinations {
                tabDestination.parentDestinationID = destination.id
            }
            
            return destination

        } else {
            return nil
        }
        
        
    }
    
}
