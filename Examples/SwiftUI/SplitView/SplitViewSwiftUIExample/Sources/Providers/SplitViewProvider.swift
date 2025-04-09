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
    
    public typealias Destination = NavigationSplitViewDestination<AppSplitView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    typealias UserInteractionType = AppSplitView.UserInteractionType
    
    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    var initialContent: [NavigationSplitViewColumn: RouteDestinationType]
    
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
                
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
        
        let splitViewDestination = NavigationSplitViewDestination<AppSplitView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>(destinationType: DestinationType.splitView, destinationsForColumns: destinationsForColumns, destinationConfigurations: destinationPresentations, parentDestinationID: configuration.parentDestinationID)

        let splitView = AppSplitView(destination: splitViewDestination)
        splitViewDestination.assignAssociatedView(view: splitView)
        
        return splitViewDestination
        
    }
    

}

