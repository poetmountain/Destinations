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
    
    enum Events: EventTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias EventType = Events
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias Destination = NavigationSplitViewDestination<Self, EventType, DestinationType, ContentType, TabType, InteractorType>
        
    @State public var destinationState: DestinationInterfaceState<Destination>

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    init(destination: Destination) {
        let state = DefaultDestinationState(destination: destination)
        self.destinationState = DestinationInterfaceState(destination: destination, state: state)
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

