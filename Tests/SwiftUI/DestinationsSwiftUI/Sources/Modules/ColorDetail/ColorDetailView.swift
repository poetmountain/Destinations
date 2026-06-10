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
final class ColorDetailInterfaceState: DestinationStateable, DestinationTypes {

    @AutoCaseIterable
    enum Events: EventTypeable, Equatable {
        case goBack
        case moveToNearest

        var rawValue: String {
            switch self {
                case .goBack:
                    return "goBack"
                case .moveToNearest:
                    return "moveToNearest"
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

    typealias Destination = ViewDestination<ColorDetailView, Events, RouteDestinationType, AppContentType, AppTabType, InteractorType>

    var destination: Destination

    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
    }
}

struct ColorDetailView: ViewDestinationInterfacing, DestinationTypes {

    typealias EventType = ColorDetailInterfaceState.Events
    typealias Destination = ColorDetailInterfaceState.Destination
    typealias InteractorType = ColorDetailInterfaceState.InteractorType

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
