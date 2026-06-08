//
//  ColorsListView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class ColorsListInterfaceState: NavigationDestinationStateable {
    typealias Destination = ColorsListDestination

    var destination: Destination

    var navigator: any DestinationPathNavigating = DestinationNavigator()

    var stateModel: (any ColorsListStateModeling)

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destination = destination
        self.stateModel = state
        navigator.navigatorDestinationID = destination.id
    }
}

struct ColorsListView: NavigatingDestinationInterfacing, DestinationTypes {
    
    typealias EventType = ColorsListDestination.Events
    typealias Destination = ColorsListDestination
    
    @State public var destinationState: ColorsListInterfaceState

    @State var areDatasourcesSetup = false

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destinationState = ColorsListInterfaceState(destination: destination, state: state)
    }
    
    public var body: some View {
        VStack {
            NavigationStack(path: $destinationState.navigator.navigationPath, root: {
                VStack {
                    Text("Colors List")
                    List(stateModel.items, selection: $destinationState.stateModel.selectedItem) { item in
                        ColorsListRow(item: item)
                    }
                    .listStyle(.plain)
                    .id(destination().listID)
                    
                    
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding()
                    
                    .onChange(of: stateModel.selectedItem, { [weak stateModel = stateModel] (oldValue: UUID?, newValue: UUID?) in
                        if let newValue, let stateModel, let item = stateModel.items.first(where: { $0.id == newValue }) {
                            stateModel.handleEvent(.color(model: item), content: nil)

                            Task {
                                try? await Task.sleep(for: .milliseconds(80))
                                stateModel.selectedItem = nil
                            }
                        }

                    })
                }
                .navigationDestination(for: UUID.self) { [weak destination = destination()] destinationID in
                    if let destinationToBuild = destination?.childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                        buildView(for: destinationToBuild)
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
    

}
