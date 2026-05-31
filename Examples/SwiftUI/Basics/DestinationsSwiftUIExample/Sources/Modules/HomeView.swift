//
//  HomeView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct HomeView: ViewDestinationInterfacing, DestinationTypes {
    
    enum Events: String, EventTypeable {
        case pathPresent

        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias EventType = Events
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias Destination = ViewDestination<HomeView, EventType, DestinationType, ContentType, TabType, InteractorType>
    

    @State public var destinationState: DestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
        
    @State private var selectedItem: ColorViewModel.ID?
    
    init(destination: Destination) {
        let state = DefaultDestinationState(destination: destination)
        self.destinationState = DestinationInterfaceState(destination: destination, state: state)
    }
    
    var body: some View {
        VStack {
            Text("Home View")
            Button("Link to path") {
                destination().handleEvent(.pathPresent)
            }
            .padding()
            .foregroundStyle(.white)
            .background(Color.blue)
            .clipShape(Capsule())
        }
    }

}

