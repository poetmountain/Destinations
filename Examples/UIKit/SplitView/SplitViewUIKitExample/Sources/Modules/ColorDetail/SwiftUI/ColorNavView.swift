//
//  ColorNavView.swift
//  SplitViewUIKitExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorNavView: View, NavigatingDestinationInterfacing, SwiftUIHostedInterfacing, AppDestinationTypes {

    typealias UserInteractionType = ColorNavDestination.UserInteractions
    typealias Destination = ColorNavDestination
    
    @State var destinationState: NavigationDestinationInterfaceState<Destination>

    @State var hostingState: SwiftUIHostingState<ColorNavView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>

    init(destination: Destination, parentDestination: SwiftUIContainerDestination<ColorNavView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
        self.hostingState = SwiftUIHostingState<ColorNavView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>(destination: parentDestination)

    }
    
    var body: some View {

        VStack(alignment: .leading) {
            NavigationStack(path: $destinationState.navigator.navigationPath, root: {

                VStack {
                    Text("Colors")
                }
                
                .navigationDestination(for: UUID.self) { [weak destinationState] destinationID in
                    if let destination = destinationState?.destination.childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                        buildView(for: destination)
                    }
                }


            })

            Spacer()

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

