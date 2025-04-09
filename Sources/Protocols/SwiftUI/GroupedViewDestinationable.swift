//
//  GroupedViewDestinationable.swift
//  Destinations
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a type of Destination which manages child Destinations in a SwiftUI project.
@MainActor public protocol GroupedViewDestinationable<DestinationType, ContentType, TabType>: ViewDestinationable, GroupedDestinationable {}
