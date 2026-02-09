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
        
    public enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
        
    }

    typealias Destination = DynamicDestination

    @State public var destinationState: DestinationInterfaceState<Destination>

    public var id = UUID()
    
    @ViewBuilder public var content: Content
    
    public init(destination: Destination, @ViewBuilder content: () -> Content) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        self.content = content()
    }

    
    public var body: some View {
        content
    }
    
    public static func == (lhs: DynamicView<Content>, rhs: DynamicView<Content>) -> Bool {
        lhs.id == rhs.id
    }
}
