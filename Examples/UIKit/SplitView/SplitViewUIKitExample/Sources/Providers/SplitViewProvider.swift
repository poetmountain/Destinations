//
//  SplitViewProvider.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations


final class SplitViewProvider: ControllerDestinationProviding, AppDestinationTypes {
    
    public typealias Destination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = StartViewController.UserInteractionType
    public typealias InteractorType = AppInteractorType
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>] = [:]
    
    var initialContent: [UISplitViewController.Column: RouteDestinationType]
    
    init(initialContent: [UISplitViewController.Column: RouteDestinationType], presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        self.initialContent = initialContent
        
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
                
        var destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<PresentationConfiguration>] = [:]
        
        // create initial content for each column
        var childDestinations: [any ControllerDestinationable] = []
        for (column, contentType) in initialContent {
            let splitViewConfiguration = configuration
            splitViewConfiguration.destinationType = contentType
            if contentType == .colorNav {
                splitViewConfiguration.contentType = .color(model: ColorViewModel(color: .red, name: "Red"))
            }
            
            if let destination = appFlow.buildDestination(for: splitViewConfiguration) {
                destinationsForColumns[column] = destination
                childDestinations.append(destination)
            }
        }
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations)

        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneOverSecondary
        splitViewDestination.assignAssociatedController(controller: splitViewController)

        for destination in childDestinations {
            splitViewDestination.setParentID(id: destination.id)
        }
        
        return splitViewDestination
        
    }
    
}
