//
//  DynamicRouteView.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class DynamicRouteInterfaceState: NavigationDestinationStateable, DestinationTypes {
    
    enum Events: String, EventTypeable {
        case navigate
    }

    enum InteractorType: InteractorTypeable {
    }
    
    typealias Destination = NavigationViewDestination<Events, DynamicRouteView, DestinationType, AppContentType, TabType, InteractorType>

    var destination: Destination

    var navigator: any DestinationPathNavigating = DestinationNavigator()

    var stateModel: DynamicRouteState

    init(destination: Destination, state: DynamicRouteState) {
        self.destination = destination
        self.stateModel = state
        navigator.navigatorDestinationID = destination.id
    }
}

struct DynamicRouteView: NavigatingDestinationInterfacing, DestinationTypes {

    typealias EventType = DynamicRouteInterfaceState.Events
    typealias InteractorType = DynamicRouteInterfaceState.InteractorType
    typealias Destination = DynamicRouteInterfaceState.Destination

    @State var destinationState: DynamicRouteInterfaceState

    init(destination: Destination, state: DynamicRouteState) {
        self.destinationState = DynamicRouteInterfaceState(destination: destination, state: state)
    }

    var body: some View {
        NavigationStack(path: $destinationState.navigator.navigationPath, root: {
            VStack(spacing: 24) {
                Text("Dynamic Routes")
                    .font(.title)

                Text("Select a destination below and tap Navigate. The **DynamicRouteAssistant** will dynamically change the destination type of the same **DestinationPresentation** at runtime based on the Route sent with the ContentType of the request.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                Picker("Destination", selection: $destinationState.stateModel.selectedRoute) {
                    Text("Welcome").tag(Route.welcome)
                    Text("Info").tag(Route.info)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Button("Navigate") {
                    stateModel.handleEvent(.navigate)
                }
                .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .ignoresSafeArea(.container, edges: .vertical)
            .navigationDestination(for: UUID.self) { [weak destination = destination()] destinationID in
                if let destinationToBuild = destination?.childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                    buildView(for: destinationToBuild)
                }
            }
        })
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
