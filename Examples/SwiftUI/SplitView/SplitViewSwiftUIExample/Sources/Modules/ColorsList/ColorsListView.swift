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
final class ColorsListInterfaceState: DestinationStateable, AppDestinationTypes {
    
    @AutoCaseIterable
    enum Events: EventTypeable {
        case color(model: ColorViewModel?)
        case retrieveInitialColors

        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .retrieveInitialColors:
                    return "retrieveInitialColors"
            }
        }

        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    enum InteractorType: InteractorTypeable {
        case colors
    }
    
    typealias Destination = ViewDestination<ColorsListView, Events, RouteDestinationType, AppContentType, AppTabType, InteractorType>

    var destination: Destination

    var stateModel: (any ColorsListStateModeling)

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destination = destination
        self.stateModel = state
    }
}

struct ColorsListView: ViewDestinationInterfacing, AppDestinationTypes {

    typealias Destination = ColorsListInterfaceState.Destination
    typealias EventType = ColorsListInterfaceState.Events
    typealias InteractorType = ColorsListInterfaceState.InteractorType
    
    @State public var destinationState: ColorsListInterfaceState

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destinationState = ColorsListInterfaceState(destination: destination, state: state)
    }

    public var body: some View {
        VStack {
            VStack {
                List(destinationState.stateModel.items, selection: $destinationState.stateModel.selectedItem) { item in
                    ColorsListRow(item: item)
                }
                .listStyle(.plain)
                .id(destination().id)
                .onChange(of: destinationState.stateModel.selectedItem, { [weak stateModel = destinationState.stateModel, weak destination = destination()] oldValue, newValue in
                    if let newValue, let item = stateModel?.items.first(where: { $0.id == newValue }) {
                        destination?.handleEvent(.color(model: item))
                    }
                })
            }
        }
    }

}
