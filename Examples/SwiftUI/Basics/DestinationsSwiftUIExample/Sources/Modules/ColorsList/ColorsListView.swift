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
final class ColorsListInterfaceState: NavigationDestinationStateable, DestinationTypes {
    
    @AutoCaseIterable
    enum Events: EventTypeable {
        case color
        case retrieveInitialColors
        case moreButton

        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .retrieveInitialColors:
                    return "retrieveInitialColors"
                case .moreButton:
                    return "moreButton"
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
    
    typealias Destination = NavigationViewDestination<Events, ColorsListView, RouteDestinationType, AppContentType, AppTabType, InteractorType>

    /// The Destination which user interaction events are sent to.
    var destination: Destination

    /// An object which manages the state of the associated interface's navigation stack.
    var navigator: any DestinationPathNavigating = DestinationNavigator()

    var stateModel: (any ColorsListStateModeling)

    init(destination: Destination, state: (any ColorsListStateModeling)) {
        self.destination = destination
        self.stateModel = state
        navigator.navigatorDestinationID = destination.id
    }
}

struct ColorsListView: NavigatingDestinationInterfacing, DestinationTypes {

    typealias Destination = ColorsListInterfaceState.Destination
    typealias EventType = ColorsListInterfaceState.Events
    typealias InteractorType = ColorsListInterfaceState.InteractorType

    @State var destinationState: ColorsListInterfaceState

    @State var isPresented: Bool = false

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
                    .id(destination().id)


                    Button("Show More") {
                        stateModel.handleEvent(.moreButton, content: nil)
                    }
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding()

                    .onChange(of: stateModel.selectedItem) { [weak stateModel = stateModel] (oldValue: UUID?, newValue: UUID?) in
                        if let newValue, let stateModel, let item = stateModel.items.first(where: { $0.id == newValue }) {
                            stateModel.handleEvent(.color, content: .color(model: item))

                            Task { [weak stateModel] in
                                try? await Task.sleep(for: .milliseconds(80))
                                stateModel?.selectedItem = nil
                            }
                        }

                    }
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
        .onDestinationDisappear(destination: destinationToBuild, navigationDestination: destination())
        .goBackButton {
            backToPreviousDestination(currentDestination: destinationToBuild)
        }
    }




}
