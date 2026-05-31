//
//  InfoView.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct InfoView: ViewDestinationInterfacing, DestinationTypes {

    enum Events: EventTypeable {
        var rawValue: String {
            ""
        }
        
    }

    typealias EventType = Events
    typealias Destination = ViewDestination<InfoView, EventType, DestinationType, ContentType, TabType, InteractorType>

    @State var destinationState: DestinationInterfaceState<Destination>

    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "info.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("Info")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            Text("This destination was reached dynamically via the **.info** route.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
        .ignoresSafeArea(.container, edges: .vertical)
    }
}
