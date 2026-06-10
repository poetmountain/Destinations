//
//  ColorDetailView.swift
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class ColorDetailInterfaceState: DestinationStateable, AppDestinationTypes {

    @AutoCaseIterable
    enum Events: String, EventTypeable {
        case none

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    typealias Destination = ViewDestination<ColorDetailView, Events, DestinationType, ContentType, TabType, InteractorType>

    var destination: Destination

    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
    }
}

struct ColorDetailView: ViewDestinationInterfacing, AppDestinationTypes {

    typealias EventType = ColorDetailInterfaceState.Events
    typealias Destination = ColorDetailInterfaceState.Destination

    @State var destinationState: ColorDetailInterfaceState

    init(destination: Destination, state: ColorDetailState) {
        self.destinationState = ColorDetailInterfaceState(destination: destination, state: state)
    }


    var body: some View {

        VStack(alignment: .leading) {

                VStack {
                    Text("Color \(stateModel.colorModel?.name ?? "")")
                    Circle()
                        .fill(Color(stateModel.colorModel?.color ?? .black))
                        .frame(width: 200, height: 200)

                }


            Spacer()

        }
    }


}


public struct DynamicViewModel: Equatable, Hashable {

    let id: UUID = UUID()

    var view: ContainerView<AnyView>?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
