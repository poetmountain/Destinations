//
//  TabBarProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct TabBarProvider: ViewDestinationProviding, DestinationTypes {
    
    typealias DestinationType = AppTabView.DestinationType
    typealias ContentType = AppTabView.ContentType
    typealias UserInteractionType = AppTabView.UserInteractions
    typealias InteractorType = AppTabView.InteractorType
    typealias TabType = AppTabView.TabType
    
    public typealias Destination = TabViewDestination<AppTabView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>

    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        guard case let RouteDestinationType.tabBar(tabs: tabs) = destinationType else { return nil }
        
        var tabTypes: [TabType] = []
        var typesForDestinations: [TabType: UUID] = [:]
        var tabDestinations: [any ViewDestinationable<DestinationType, ContentType, TabType>] = []
        
        // create starting content for each tab
        for tabType in tabs {
            let tabContentType: RouteDestinationType
            switch tabType {
                case .palettes:
                    tabContentType = .colorsList
                case .home:
                    tabContentType = .home
                case .counter:
                    tabContentType = .counter
            }
            let tabConfig = configuration
            tabConfig.destinationType = tabContentType
            
            
            if let destination = appFlow.buildDestination(for: tabConfig) {
                tabTypes.append(tabType)
                tabDestinations.append(destination)
                typesForDestinations[tabType] = destination.id
            }
        }
        
        if let destination = Destination(type: RouteDestinationType.tabBar(tabs: tabs), tabDestinations: tabDestinations, tabTypes: tabTypes, selectedTab: .palettes, navigationConfigurations: navigationPresentations) {
            
            let tabView = AppTabView(destination: destination)
            destination.assignAssociatedView(view: tabView)

            return destination

        } else {
            return nil
        }
        
        
    }
    
}
