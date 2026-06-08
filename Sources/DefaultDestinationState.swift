//
//  DefaultDestinationState.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

@Observable
public final class DefaultDestinationState<Destination: Destinationable>: StateModeling {

    public typealias EventType = Destination.EventType
    public typealias InteractorType = Destination.InteractorType
    public typealias ContentType = Destination.ContentType

    public var destination: Destination?

    public init(destination: Destination? = nil) {
        self.destination = destination
    }

    public func handleEvent(_ type: Destination.EventType, content: Destination.ContentType? = nil) {
        destination?.handleThrowable { [weak destination] in
            try destination?.performAction(for: type, content: content)
        }
    }
}
