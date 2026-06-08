//
//  ColorDetailView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class ColorDetailInterfaceState: DestinationStateable {
    typealias Destination = ColorDetailDestination

    var destination: Destination

    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
        self.destination.stateModel = state
        state.destination = destination
    }
}

struct ColorDetailView: ViewDestinationInterfacing, DestinationTypes {
    
    typealias EventType = ColorDetailDestination.Events
    typealias Destination = ColorDetailDestination
            
    @State var destinationState: ColorDetailInterfaceState

    @State var areDatasourcesSetup = false

    init(destination: Destination, state: ColorDetailState) {
        self.destinationState = ColorDetailInterfaceState(destination: destination, state: state)
    }
    
    var body: some View {
        VStack {
            Text("Color \(stateModel.colorModel?.name ?? "")")
            Circle()
                .fill(Color(stateModel.colorModel?.color ?? .black))
                .frame(width: 200, height: 200)
        }
    }

}


struct ColorDetailSelectionModel: Hashable {
    
    var color: ColorViewModel?
    var targetID: UUID?
    
}
