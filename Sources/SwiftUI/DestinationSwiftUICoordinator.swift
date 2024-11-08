//
//  DestinationSwiftUICoordinator.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This class coordinates the presentation of a Destination within the SwiftUI framework.
public final class DestinationSwiftUICoordinator: NSObject, DestinationSwiftUICoordinating {
    
    /// A reference to the root `View` in a SwiftUI app.
    public var rootView: (any View)?
    
    /// A closure which is called when a Destination should be removed from the ecosystem, typically after it's associated UI object is no longer being presented.
    public var removeDestinationClosure: RemoveDestinationClosure?
    
    /// The Destination that currently should be presented.
    public var destinationToPresent: (any Destinationable)?
    
    /// A delegate protocol object which can subscribe to this object to receive updates about the status of destination presentations.
    public weak var delegate: DestinationInterfaceCoordinatorDelegate?
    
    
    /// The initializer.
    /// - Parameter rootView: A reference to the root `View` in a SwiftUI app.
    public init(rootView: (any View)? = nil) {
        super.init()
        self.rootView = rootView
    }
    
    /// Handles the presentation of a Destination's associated `View` in a SwiftUI app.
    /// - Parameters:
    ///   - destination: The Destination to present.
    ///   - currentDestination: The currently presented Destination.
    ///   - parentOfCurrentDestination: The parent of the current Destination.
    ///   - configuration: The configuration object for this presentation.
    public func presentViewDestination<PresentationConfiguration: DestinationPresentationConfiguring>(
        destination: (any ViewDestinationable<PresentationConfiguration>)? = nil,
        currentDestination: (any ViewDestinationable<PresentationConfiguration>)?,
        parentOfCurrentDestination: (any ViewDestinationable)?,
        configuration: PresentationConfiguration) {
            
            destinationToPresent = destination
            
            configuration.handlePresentation(destinationToPresent: destination, currentDestination: currentDestination, parentOfCurrentDestination: parentOfCurrentDestination, removeDestinationClosure: removeDestinationClosure)
            
    }
    
}
