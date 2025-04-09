//
//  ViewDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A protocol representing a SwiftUI `View` that is associated with a Destination.
@MainActor public protocol ViewDestinationInterfacing<DestinationType, ContentType, TabType>: DestinationInterfacing, View where Destination: ViewDestinationable<DestinationType, ContentType, TabType> {

}

public extension ViewDestinationInterfacing {
    
    /// A `ViewBuilder` method that returns a strongly-typed `View` associated with the specified Destiantion.
    /// - Parameter destinationID: The identifier of the Destination.
    /// - Returns: A strongly-typed `View` associated with the specified Destination.
    @ViewBuilder func destinationView(for destination: any ViewDestinationable<DestinationType, ContentType, TabType>) -> (some View)? {
        if let view = destination.currentView() {
            AnyView(view)
        }
    }
}
