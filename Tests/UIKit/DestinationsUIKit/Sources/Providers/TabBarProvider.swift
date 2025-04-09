//
//  TabBarProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct TabBarProvider: ControllerDestinationProviding, DestinationTypes {
    
    typealias UserInteractionType = AppTabBarController.UserInteractionType
    public typealias Destination = TabBarControllerDestination<AppTabBarController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>

    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        guard case let RouteDestinationType.tabBar(tabs: tabs) = destinationType else { return nil }
        
        var tabTypes: [TabType] = []
        var tabDestinations: [any ControllerDestinationable<DestinationType, AppContentType, TabType>] = []
        
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
            }
        }
                
        if let destination = TabBarControllerDestination<AppTabBarController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>(type: .tabBar(tabs: tabTypes), tabDestinations: tabDestinations, tabTypes: tabTypes, selectedTab: .palettes, navigationConfigurations: navigationPresentations) {
            
            let tabController = AppTabBarController(destination: destination)
            destination.assignAssociatedController(controller: tabController)

            return destination
        } else {
            return nil
        }
        
    }
    
}
