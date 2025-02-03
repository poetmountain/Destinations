//
//  DestinationProvider.swift
///
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import SwiftUI
import Destinations
@testable import DestinationsUIKit

final class DestinationProvider<ControllerDestinationableType: ControllerDestinationable, UserInteractionType: UserInteractionTypeable>: ControllerDestinationProviding, DestinationTypes {
    
    public typealias ControllerDestinationableType = ControllerDestinationableType
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = UserInteractionType
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var systemNavigationData: [SystemNavigationType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]

    init(presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, systemNavigationData: [SystemNavigationType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let systemNavigationData {
            self.systemNavigationData = systemNavigationData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> (any ControllerDestinationable)? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        switch destinationType {

            case .start:
                
                let destinationPresentations = buildPresentations() as? AppDestinationConfigurations<StartViewController.UserInteractions, PresentationConfiguration>
                
                let navigationPresentations = buildSystemPresentations()
                
                let destination = NavigationControllerDestination<StartViewController.UserInteractions, StartViewController, StartViewController.PresentationConfiguration, StartViewController.InteractorType>(destinationType: .start, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

                let controller = StartViewController(destination: destination)
                destination.assignAssociatedController(controller: controller)

                 return destination
                
            case .colorsList:

                let destinationPresentations = buildPresentations() as? AppDestinationConfigurations<ColorsListDestination.UserInteractions, PresentationConfiguration>
                
                let navigationPresentations = buildSystemPresentations()
                

                let destination = ColorsListDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

                let controller = ColorsViewController(destination: destination)
                destination.assignAssociatedController(controller: controller)

                 let datasource = ColorsDatasource()
                 destination.setupInteractor(interactor: datasource, for: .colors)
                
                 return destination
                
            case .colorDetail:

                var colorModel: ColorViewModel?
                if let contentType = configuration.contentType, case let .color(model) = contentType {
                    colorModel = model
                }

                let destinationPresentations = buildPresentations() as? AppDestinationConfigurations<ColorDetailDestination.UserInteractions, PresentationConfiguration>
                let navigationPresentations = buildSystemPresentations()
                
                let destination = ColorDetailDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
                
                let datasource = ColorsDatasource()
                destination.setupInteractor(interactor: datasource, for: .test)
                
                let controller = ColorDetailViewController(destination: destination, colorModel: colorModel)
                destination.assignAssociatedController(controller: controller)

                return destination
                
            case .home:
                
                let destinationPresentations = buildPresentations() as? AppDestinationConfigurations<HomeUserInteractions, PresentationConfiguration>
                let navigationPresentations = buildSystemPresentations()
                
                let destination = ControllerDestination<HomeUserInteractions, HomeViewController, PresentationConfiguration, InteractorType>(destinationType: .home, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
                
                let controller = HomeViewController(destination: destination)
                destination.assignAssociatedController(controller: controller)
                
                return destination
                
            case .sheet:
                
                let destinationPresentations = buildPresentations() as? AppDestinationConfigurations<SheetViewController.UserInteractions, PresentationConfiguration>
                let navigationPresentations = buildSystemPresentations()
                

                let destination = SheetDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
                
                let contentController = SheetContentViewController(destination: destination, content: configuration.contentType)
                let controller = SheetViewController(destination: destination, rootController: contentController)
                destination.assignAssociatedController(controller: controller)
                
                return destination
                
            case .tabBar(tabs: let tabs):
                
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

            case .splitView, .colorNav, .colorDetailSwiftUI:
                return nil
            default: return nil
        }
        
    }
    

}
