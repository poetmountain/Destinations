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
    
    enum Events: EventTypeable, Equatable {

        case colorDetailButton

        var rawValue: String {
            switch self {
                case .colorDetailButton:
                    return "colorDetailButton"
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
    
    typealias Destination = ViewDestination<ColorDetailView, Events, DestinationType, AppContentType, TabType, InteractorType>

    var destination: Destination

    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
        self.destination.stateModel = state
    }
}

struct ColorDetailView: ViewDestinationInterfacing, SheetPresenting, DestinationTypes {

    typealias Destination = ColorDetailInterfaceState.Destination
    typealias EventType = ColorDetailInterfaceState.Events
    typealias InteractorType = ColorDetailInterfaceState.InteractorType

    @State var destinationState: ColorDetailInterfaceState

    @State var areDatasourcesSetup = false

    @State var sheetPresentation = SheetPresentation()

    init(destination: Destination, state: ColorDetailState) {
        self.destinationState = ColorDetailInterfaceState(destination: destination, state: state)

        sheetPresentation.dismissedClosure = {
            print("custom dismissed!")
        }
    }

    var body: some View {
        VStack {
            Text("Color \(stateModel.colorModel?.name ?? "")")
            Circle()
                .fill(Color(stateModel.colorModel?.color ?? .black))
                .frame(width: 200, height: 200)

            Button(action: { [weak stateModel] in
                stateModel?.handleEvent(.colorDetailButton)
            }, label: {
                Text("Present")
            })

        }
        .destinationSheet(presentation: sheetPresentation)

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
