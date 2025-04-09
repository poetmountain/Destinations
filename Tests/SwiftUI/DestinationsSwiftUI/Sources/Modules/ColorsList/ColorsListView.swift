//
//  ColorsListView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorsListView: NavigatingDestinationInterfacing, DestinationTypes {
    
    typealias UserInteractionType = ColorsListDestination.UserInteractions
    typealias Destination = ColorsListDestination
    
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
        
    @State var selectedItem: ColorViewModel.ID?

    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
    }
    
    public var body: some View {
        VStack {
            NavigationStack(path: $destinationState.navigator.navigationPath, root: {
                VStack {
                    Text("Colors List")
                    List(destinationState.destination.items, selection: $selectedItem) { item in
                        ColorsListRow(item: item)
                    }
                    .listStyle(.plain)
                    .id(destination().listID)
                    
                    
                    Button("Show More") {
                        self.requestMoreButtonAction()
                    }
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding()
                    
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
                .navigationDestination(for: UUID.self) { [weak destinationState] destinationID in
                    if let destination = destinationState?.destination.childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                        buildView(for: destination)
                    }
                }

            })
        }
    }
    

    
    @ViewBuilder func buildView(for destinationToBuild: any ViewDestinationable<DestinationType, ContentType, TabType>) -> (some View)? {
        destinationView(for: destinationToBuild)
        .id(destinationToBuild.id.uuidString)
        .goBackButton {
            backToPreviousDestination(currentDestination: destinationToBuild)
        }
        .onDestinationDisappear(destination: destinationToBuild, navigationDestination: destination())
    }
    
    
    func requestMoreButtonAction() {
        let destination = destination()
        destination.handleThrowable { [weak destination] in
            try destination?.performInterfaceAction(interactionType: .moreButton)
        }
    }
    
}

