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
    
    public typealias Destination = SplitViewControllerDestination<UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    public typealias UserInteractionType = StartViewController.UserInteractionType
    public typealias InteractorType = AppInteractorType
    
    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>] = [:]
    
    var initialContent: [UISplitViewController.Column: RouteDestinationType]
    
    init(initialContent: [UISplitViewController.Column: RouteDestinationType], presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        self.initialContent = initialContent
        
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination? {
                
        var destinationsForColumns: [UISplitViewController.Column: any ControllerDestinationable<DestinationType, ContentType, TabType>] = [:]
        
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
        
        let splitViewDestination = SplitViewControllerDestination<UserInteractionType, DestinationType, ContentType, TabType, InteractorType>(type: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations)

        let splitViewController = SplitViewController(destination: splitViewDestination, style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneOverSecondary
        splitViewDestination.assignAssociatedController(controller: splitViewController)

        for destination in childDestinations {
            splitViewDestination.setParentID(id: destination.id)
        }
        
        return splitViewDestination
        
    }
    
}
