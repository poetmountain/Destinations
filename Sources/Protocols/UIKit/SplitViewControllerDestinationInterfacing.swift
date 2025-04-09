//
//  SplitViewControllerDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A protocol representing a `UISplitViewController` class which conforms to Destinations.
@MainActor public protocol SplitViewControllerDestinationInterfacing: ControllerDestinationInterfacing, UISplitViewController where Destination: SplitViewControllerDestinationable<DestinationType, ContentType, TabType> {
    
}
