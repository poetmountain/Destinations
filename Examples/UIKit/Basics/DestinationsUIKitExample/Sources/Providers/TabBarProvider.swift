//
//  TabBarProvider.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 10/24/24.
//

import Foundation
import Destinations

final class TabBarProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = AppTabBarController.UserInteractionType
    public typealias InteractorType = AppTabBarController.InteractorType
    
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
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> (any ControllerDestinationable)? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        guard case let RouteDestinationType.tabBar(tabs: tabs) = destinationType else { return nil }
        
        var tabTypes: [TabType] = []
        var tabDestinations: [any ControllerDestinationable<PresentationConfiguration>] = []
        
        // create starting content for each tab
        for tabType in tabs {
            let tabContentType: RouteDestinationType
            switch tabType {
                case .palettes:
                    tabContentType = .colorsList
                case .home:
                    tabContentType = .home
                case .swiftUI:
                    tabContentType = .swiftUI
            }
            let tabConfig = configuration
            tabConfig.destinationType = tabContentType
            
            
            
            if let destination = appFlow.buildDestination(for: tabConfig) {
                tabTypes.append(tabType)
                tabDestinations.append(destination)
            }
        }
        
        let navigationPresentations = buildSystemPresentations()
        
        if let destination = TabBarControllerDestination<PresentationConfiguration, AppTabBarController>(type: .tabBar(tabs: tabTypes), tabDestinations: tabDestinations, tabTypes: tabTypes, selectedTab: .palettes, navigationConfigurations: navigationPresentations) {
            
            let tabController = AppTabBarController(destination: destination)
            destination.assignAssociatedController(controller: tabController)
            
            for tabDestination in tabDestinations {
                tabDestination.parentDestinationID = destination.id
            }
            
            return destination
        } else {
            return nil
        }
        
    }
    
}
