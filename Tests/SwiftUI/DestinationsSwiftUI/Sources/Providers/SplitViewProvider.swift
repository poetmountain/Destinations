//
//  SplitViewProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class SplitViewProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias ViewDestinationableType = NavigationSplitViewDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = AppSplitView.UserInteractions
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
    
    var initialContent: [NavigationSplitViewColumn: RouteDestinationType]

    init(initialContent: [NavigationSplitViewColumn: RouteDestinationType], presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        self.initialContent = initialContent
        
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> (any ViewDestinationable)? {
        
        let destinationPresentations = buildPresentations()
        
        var destinationsForColumns: [NavigationSplitViewColumn: any ViewDestinationable<PresentationConfiguration>] = [:]
        
        // create initial content for each column
        var childDestinations: [any ViewDestinationable] = []
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
        
        let splitViewDestination = NavigationSplitViewDestination<PresentationConfiguration, AppSplitView>(destinationType: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, parentDestinationID: configuration.parentDestinationID)

        let splitView = AppSplitView(destination: splitViewDestination)
        splitViewDestination.assignAssociatedView(view: splitView)
        
        return splitViewDestination
        
    }
    

}

