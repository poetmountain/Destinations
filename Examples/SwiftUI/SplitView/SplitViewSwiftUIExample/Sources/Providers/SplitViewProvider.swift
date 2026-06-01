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
    
    public typealias Destination = AppSplitView.Destination
    typealias EventType = AppSplitView.EventType
    
    public var presentationsData: [Destination.EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    var initialContent: [NavigationSplitViewColumn: RouteDestinationType]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
                
        var destinationsForColumns: [NavigationSplitViewColumn: any ViewDestinationable<DestinationType, ContentType, TabType>] = [:]
        
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
        
        let splitViewDestination = Destination(destinationType: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, parentDestinationID: configuration.parentDestinationID)

        let splitView = AppSplitView(destination: splitViewDestination)
        splitViewDestination.assignAssociatedView(view: splitView)
        
        return splitViewDestination
        
    }
    

}
