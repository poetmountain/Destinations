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
final class ColorDetailInterfaceState: DestinationStateable, AppDestinationTypes {
    
    enum Events: EventTypeable, Equatable {
        
        var rawValue: String {
            ""
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
        self.destination.stateModel = state
    }
}

struct ColorDetailView: ViewDestinationInterfacing, AppDestinationTypes {

    typealias Destination = ColorDetailInterfaceState.Destination
    typealias EventType = ColorDetailInterfaceState.Events
    typealias InteractorType = ColorsListInterfaceState.InteractorType

    @State var destinationState: ColorDetailInterfaceState

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

public struct DynamicViewModel: Equatable, Hashable {

    let id: UUID = UUID()

    var view: ContainerView<AnyView>?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
