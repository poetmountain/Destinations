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
    
    enum UserInteractions: String, UserInteractionTypeable {
        case pathPresent

        static func == (lhs: UserInteractions, rhs: UserInteractions) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias Destination = ViewDestination<HomeView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    

    @State public var destinationState: DestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
        
    @State private var selectedItem: ColorViewModel.ID?
    
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack {
            Text("Home View")
            Button("Link to path") {
                destination().handleThrowable(closure: {
                    try destination().performInterfaceAction(interactionType: .pathPresent)
                })
            }
            .padding()
            .foregroundStyle(.white)
            .background(Color.blue)
            .clipShape(Capsule())
        }
    }

}

