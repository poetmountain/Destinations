//
//  AppTabView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

enum TabSelections: EventTypeable {
    case back
    
    public var rawValue: String {
        switch self {
            case .back:
                return "back"
        }
    }
}

struct AppTabView: TabBarViewDestinationInterfacing, DestinationTypes {
        
    enum Events: EventTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias EventType = Events
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias Destination = TabViewDestination<Self, EventType, DestinationType, ContentType, TabType, InteractorType>
        
    @State public var destinationState: DestinationInterfaceState<Destination>


    init(destination: Destination) {
        let state = DefaultDestinationState(destination: destination)
        self.destinationState = DestinationInterfaceState(destination: destination, state: state)
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $destinationState.destination.selectedTab) {
                ForEach($destinationState.destination.activeTabs, id: \.self) { tab in
                    buildView(for: tab.wrappedValue)
                    .tag(tab.wrappedValue.type.tabName)
                    .tabItem {
                        Label(tab.wrappedValue.type.tabName, systemImage: tab.wrappedValue.type.imageName)
                    }
                }

            }
        }
    }
    
    
    @ViewBuilder func buildView(for tab: TabModel<TabType>) -> (some View)? {

        if let view = destination().rootDestination(for: tab.type)?.currentView() {
            AnyView(view)
        }

    }

}
