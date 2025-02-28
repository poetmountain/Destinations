//
//  SplitViewProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations


struct SplitViewProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    var initialContent: [UISplitViewController.Column: RouteDestinationType]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
                
        var destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<PresentationConfiguration>] = [:]
        
        // create initial content for each column
        var childDestinations: [any ControllerDestinationable] = []
        for (column, contentType) in initialContent {
            let splitViewConfiguration = configuration
            splitViewConfiguration.destinationType = contentType
            if contentType == .colorDetail {
                splitViewConfiguration.contentType = .color(model: ColorViewModel(color: .red, name: "Red"))
            }
            
            if let destination = appFlow.buildDestination(for: splitViewConfiguration) {
                DestinationsSupport.logger.log("Built destination \(destination.type) for column \(column)")
                destinationsForColumns[column] = destination
                childDestinations.append(destination)
            }
        }
        
        let splitViewDestination = SplitViewControllerDestination<PresentationConfiguration, SplitViewController<UserInteractionType, PresentationConfiguration, InteractorType>>(type: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, parentDestinationID: configuration.parentDestinationID)

        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        
        return splitViewDestination
        
    }
    
}
