//
//  ColorsListView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorsListView: ViewDestinationInterfacing, AppDestinationTypes {
    
    typealias UserInteractionType = ColorsListDestination.UserInteractions
    typealias Destination = ColorsListDestination
    
    @State public var destinationState: DestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
        
    @State var selectedItem: ColorViewModel.ID?

    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    public var body: some View {
        VStack {
            VStack {
                List(destinationState.destination.items, selection: $selectedItem) { item in
                    ColorsListRow(item: item)
                }
                .listStyle(.plain)
                .id(destination().listID)
                .onChange(of: selectedItem, { [weak destinationState] oldValue, newValue in
                    if let newValue, let item = destinationState?.destination.items.first(where: { $0.id == newValue }) {
                        destinationState?.destination.handleThrowable(closure: {
                            try destinationState?.destination.performInterfaceAction(interactionType: UserInteractionType.color(model: item))
                        })
                        
                        Task {
                            try? await Task.sleep(for: .milliseconds(80))
                            selectedItem = nil
                        }
                    }
                    
                })
            }

        
        }
    }

}

