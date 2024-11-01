//
//  DestinationSwiftUICoordinating.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This protocol represents an object that coordinates the presentation of a Destination within the SwiftUI framework.
public protocol DestinationSwiftUICoordinating: DestinationInterfaceCoordinating {
    
    /// A closure which is called when a Destination should be removed from the ecosystem, typically after it's associated UI object is no longer being presented.
    var removeDestinationClosure: RemoveDestinationClosure? { get set }
    
    /// A delegate protocol object which can subscribe to this object to receive updates about the status of destination presentations.
    var delegate: DestinationInterfaceCoordinatorDelegate? { get set }
    
    /// A reference to the root `View` in a SwiftUI app.
    var rootView: (any View)? { get set }
    
    /// A reference to the root `ControllerDestinationInterfacing` object in a UIKit app.
    //var rootController: (any ControllerDestinationInterfacing)? { get set }
    
    /// The Destination that currently should be presented.
    var destinationToPresent: (any Destinationable)? { get set }
    
    /// Handles the presentation of a Destination's associated `View` in a SwiftUI app.
    /// - Parameters:
    ///   - destination: The Destination to present.
    ///   - currentDestination: The currently presented Destination.
    ///   - parentOfCurrentDestination: The parent of the current Destination.
    ///   - configuration: The configuration object for this presentation.
    func presentViewDestination<PresentationConfiguration: DestinationPresentationConfiguring>(
        destination: (any ViewDestinationable<PresentationConfiguration>)?,
        currentDestination: (any ViewDestinationable<PresentationConfiguration>)?,
        parentOfCurrentDestination: (any ViewDestinationable)?,
        configuration: PresentationConfiguration)
    
}
