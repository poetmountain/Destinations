//
//  NavigationSplitViewDestinationInterfacing.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A protocol defining a SwiftUI `View` which handles a `NavigationSplitView` and conforms to Destinations.
@MainActor public protocol NavigationSplitViewDestinationInterfacing: ViewDestinationInterfacing, View where Destination: NavigationSplitViewDestinationable<DestinationType, ContentType, TabType>, DestinationState.Destination == Destination {

}

