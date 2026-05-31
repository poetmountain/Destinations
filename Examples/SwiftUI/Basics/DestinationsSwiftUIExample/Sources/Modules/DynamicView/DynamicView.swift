//
//  DynamicView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct DynamicView<Content: View>: ViewDestinationInterfacing, DestinationTypes {

    typealias Destination = ViewDestination<DynamicView<AnyView>, GeneralAppInteractions, RouteDestinationType, AppContentType, AppTabType, AppInteractorType>

    @State public var destinationState: DestinationInterfaceState<Destination>

    public var id = UUID()

    @ViewBuilder public var content: Content

    public init(destination: Destination, @ViewBuilder content: () -> Content) {
        let state = DefaultDestinationState(destination: destination)
        self.destinationState = DestinationInterfaceState(destination: destination, state: state)
        self.content = content()
    }


    public var body: some View {
        content
    }

    public static func == (lhs: DynamicView<Content>, rhs: DynamicView<Content>) -> Bool {
        lhs.id == rhs.id
    }
}
