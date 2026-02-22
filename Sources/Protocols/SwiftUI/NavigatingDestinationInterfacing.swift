//
//  NavigatingDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A protocol representing a SwiftUI `View` that is associated with a Destination and contains a `NavigationStack`.
@MainActor public protocol NavigatingDestinationInterfacing<DestinationType, ContentType, TabType>: ViewDestinationInterfacing where DestinationState: NavigationDestinationStateable<Destination> {
    
    /// Requests that this user interface's navigator move to the previous Destination in the navigation path.
    /// - Parameter currentDestination: The current Destination associated with the interface which is currently presented. This Destination will send the system navigation message.
    func backToPreviousDestination(currentDestination: any ViewDestinationable)
}

public extension NavigatingDestinationInterfacing {
    
    func backToPreviousDestination(currentDestination: any ViewDestinationable) {
        
        var options: SystemNavigationOptions?
        if let targetID = destinationState.navigator.previousPathElement() {
            options = SystemNavigationOptions(targetID: targetID)
        } else if let parentID = currentDestination.parentDestinationID() {
            options = SystemNavigationOptions(targetID: parentID)
        } else {
            options = SystemNavigationOptions(targetID: currentDestination.id)
        }
        
        currentDestination.performSystemNavigationAction(navigationType: SystemNavigationType.navigateBackInStack, options: options)
    }
}
