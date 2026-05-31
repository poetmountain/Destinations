//
//  SplitViewController.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A `UISplitViewController` subclass which can be used as an interface for a ``SplitViewControllerDestination``.
public final class SplitViewController<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: UISplitViewController, SplitViewControllerDestinationInterfacing {
    
    public typealias Destination = SplitViewControllerDestination<EventType, DestinationType, ContentType, TabType, InteractorType>
    public typealias InteractorType = InteractorType
    public typealias EventType = EventType
    public typealias ControllerType = SplitViewController
    
    public var destinationState: DestinationInterfaceState<Destination>
    
    /// The initializer.
    /// - Parameters:
    ///   - destination: The Destination associated with this interface.
    ///   - style: The `UISplitViewController` style.
    public init(destination: Destination, style: UISplitViewController.Style) {
        let state = DefaultDestinationState(destination: destination)
        self.destinationState = DestinationInterfaceState(destination: destination, state: state)

        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
