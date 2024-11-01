//
//  ColorDetailView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations
import Combine

struct ColorDetailView: ViewDestinationInterfacing, DestinationTypes {
    
    typealias UserInteractionType = ColorDetailDestination.UserInteractions
    typealias Destination = ColorDetailDestination
            
    @State var destinationState: DestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
        
    @State private var selectedItem: ColorViewModel.ID?
    
    @State private var colorModel: ColorViewModel?
    
    init(destination: Destination, model: ColorViewModel? = nil) {
        self.destinationState = DestinationInterfaceState(destination: destination)

        if let model = model {
            _colorModel = State.init(initialValue: model)
        }
   
    }
    
    var body: some View {
        VStack {
            Text("Color \(colorModel?.name ?? "")")
            Circle()
                .fill(Color(colorModel?.color ?? .black))
                .frame(width: 200, height: 200)

        }

    }

}


struct ColorDetailSelectionModel: Hashable {
    
    var color: ColorViewModel?
    var targetID: UUID?
    
}

