//
//  ControllerDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A protocol representing UIViewControllers which conform to Destinations
@MainActor public protocol ControllerDestinationInterfacing: DestinationInterfacing, UIViewController {
    
    /// Moves back to the previous controller in a `UINavigationController`.
    func performSystemNavigationBack()

}

public extension ControllerDestinationInterfacing {
    func performSystemNavigationBack() {
        guard let navigationController else { return }
        
        var options: SystemNavigationOptions?
        if let targetController = navigationController.previousController() as? any ControllerDestinationInterfacing {
            let destination = targetController.destination()
            options = SystemNavigationOptions(targetID: destination.id )
        } else {
            let destinationID = destination().parentDestinationID()
            options = SystemNavigationOptions(targetID: destinationID)
        }
        destination().performSystemNavigationAction(navigationType: .navigateBackInStack, options: options)
        
    }
    
}

/// This protocol represents a `UINavigationController` that is associated with a Destination.
public protocol NavigationControllerDestinationInterfacing: ControllerDestinationInterfacing, UINavigationController {

}
