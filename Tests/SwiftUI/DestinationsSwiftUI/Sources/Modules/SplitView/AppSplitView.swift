//
//  AppSplitView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct AppSplitView: NavigationSplitViewDestinationInterfacing, DestinationTypes {
    
    enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = DestinationPresentation<RouteDestinationType, AppContentType, TabType>
    typealias Destination = NavigationSplitViewDestination<PresentationConfiguration, Self>
        
    @State public var destinationState: DestinationInterfaceState<Destination>

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                BindableContainerView(content: $destinationState.destination.currentSidebar)
            } content: {
                BindableContainerView(content: $destinationState.destination.currentContent)
            } detail: {
                BindableContainerView(content: $destinationState.destination.currentDetail)
            }

        }
    }
    
}

