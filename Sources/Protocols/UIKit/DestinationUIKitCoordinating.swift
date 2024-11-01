//
//  DestinationUIKitCoordinating.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This protocol represents an object that coordinates the presentation of a Destination within the UIKit framework.
public protocol DestinationUIKitCoordinating: DestinationInterfaceCoordinating, UINavigationControllerDelegate {
    
    /// A closure which is called when a Destination should be removed from the ecosystem, typically after it's associated UI object is no longer being presented.
    var removeDestinationClosure: RemoveDestinationClosure? { get set }
    
    /// A delegate protocol object which can subscribe to this object to receive updates about the status of destination presentations.
    var delegate: DestinationInterfaceCoordinatorDelegate? { get set }
    
    /// A reference to the root `ControllerDestinationInterfacing` object in a UIKit app.
    var rootController: (any ControllerDestinationInterfacing)? { get set }
    
    /// The Destination that currently should be presented.
    var destinationToPresent: (any Destinationable)? { get set }
    
    /// Handles the presentation of a Destination's associated `UIViewController` in a UIKit app.
    /// - Parameters:
    ///   - destination: The Destination to present.
    ///   - currentDestination: The currently presented Destination.
    ///   - parentOfCurrentDestination: The parent of the current Destination.
    ///   - tabBarDestinationInViewHiearchy: A TabBar controller, if one was found in the view hierarchy.
    ///   - configuration: The configuration object for this presentation.
    func presentControllerDestination<PresentationConfiguration: DestinationPresentationConfiguring>(
        destination: (any ControllerDestinationable<PresentationConfiguration>)?,
        currentDestination: (any ControllerDestinationable)?,
        parentOfCurrentDestination: (any ControllerDestinationable)?,
        tabBarDestinationInViewHiearchy: (any TabBarControllerDestinationable)?,
        configuration: PresentationConfiguration)
    
}
