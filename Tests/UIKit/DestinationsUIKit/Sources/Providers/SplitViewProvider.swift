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
    
    public typealias Destination = SplitViewControllerDestination<EventType, DestinationType, AppContentType, TabType, InteractorType>

    public var presentationsData: [Destination.EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.EventType: any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    var initialContent: [UISplitViewController.Column: RouteDestinationType]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
                
        var destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<DestinationType, AppContentType, TabType>] = [:]
        
        // create initial content for each column
        var childDestinations: [any ControllerDestinationable] = []
        for (column, contentType) in initialContent {
            let splitViewConfiguration = configuration
            splitViewConfiguration.destinationType = contentType
            if contentType == .colorDetail {
                splitViewConfiguration.contentType = .color(model: ColorViewModel(color: .red, name: "Red"))
            }
            
            if let destination = appFlow.buildDestination(for: splitViewConfiguration) {
                destinationsForColumns[column] = destination
                childDestinations.append(destination)
            }
        }
        
        let splitViewDestination = SplitViewControllerDestination<EventType, DestinationType, AppContentType, TabType, InteractorType>(type: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, parentDestinationID: configuration.parentDestinationID)

        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewDestination.assignAssociatedController(controller: splitViewController)
        
        return splitViewDestination
        
    }
    
}
