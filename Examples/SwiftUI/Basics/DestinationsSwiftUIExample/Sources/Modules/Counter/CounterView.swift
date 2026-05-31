//
//  CounterView.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class CounterInterfaceState: DestinationStateable, DestinationTypes {
    
    enum Events: EventTypeable, Equatable {

        case start
        case stop

        var rawValue: String {
            switch self {
                case .start:
                    return "start"
                case .stop:
                    return "stop"
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
        case counter
    }
    
    typealias Destination = ViewDestination<CounterView, Events, RouteDestinationType, AppContentType, AppTabType, InteractorType>

    var destination: Destination

    var stateModel: CounterState

    init(destination: Destination, state: CounterState) {
        self.destination = destination
        self.stateModel = state
        self.destination.stateModel = state
    }
}

struct CounterView: ViewDestinationInterfacing, DestinationTypes {

    typealias EventType = CounterInterfaceState.Events
    typealias Destination = CounterInterfaceState.Destination
    typealias InteractorType = CounterInterfaceState.InteractorType

    @State var destinationState: CounterInterfaceState

    init(destination: Destination, state: CounterState) {
        self.destinationState = CounterInterfaceState(destination: destination, state: state)
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Text("Counter")
                .font(.system(size: 24, weight: .semibold))
            Text("\(destinationState.stateModel.counter)")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemBlue.cgColor))

            Spacer()

            HStack {
                Button("Start counter") {
                    destinationState.stateModel.handleStartButtonTapped()
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(Capsule())

                Button("Stop counter") {
                    destinationState.stateModel.handleStopButtonTapped()
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .padding(.bottom, 50)

        }

    }

}
