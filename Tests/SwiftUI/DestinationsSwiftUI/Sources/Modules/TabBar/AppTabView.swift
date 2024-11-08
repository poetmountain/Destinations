//
//  AppTabView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

enum TabSelections: UserInteractionTypeable {
    case back
    
    public var rawValue: String {
        switch self {
            case .back:
                return "back"
        }
    }
}

struct AppTabView: TabBarViewDestinationInterfacing, DestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = DestinationPresentation<RouteDestinationType, AppContentType, TabType>
    typealias Destination = TabViewDestination<PresentationConfiguration, Self>
        
    @State public var destinationState: DestinationInterfaceState<Destination>


    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
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