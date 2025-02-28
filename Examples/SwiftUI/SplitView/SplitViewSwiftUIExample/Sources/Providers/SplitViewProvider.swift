//
//  SplitViewProvider.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations


struct SplitViewProvider: ViewDestinationProviding, AppDestinationTypes {
    
    public typealias Destination = NavigationSplitViewDestination<PresentationConfiguration, AppSplitView>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    
    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    var initialContent: [NavigationSplitViewColumn: RouteDestinationType]
    
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {
                
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

