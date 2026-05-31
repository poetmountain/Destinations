//
//  InterfaceAction.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Represents an action to be taken when a user interacts with a particular interface element.
public struct InterfaceAction<EventType: EventTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable>: Equatable, Hashable {
    
    /// A unique identifier.
    public let id = UUID()
    
    /// A closure to be run when a user interacts with a specific user interface element.
    public var function: (EventType, InterfaceActionData<DestinationType, ContentType>) -> Void

    /// A user interaction type.
    public var eventType: EventType?

    /// Model data associated with the presentation which is used by the closure.
    public var data: InterfaceActionData<DestinationType, ContentType> = InterfaceActionData()

    /// Calls the closure.
    ///
    /// > Note: This is a "magic" function used by Swift, as part of Swift proposal SE-0253. See https://github.com/swiftlang/swift-evolution/blob/main/proposals/0253-callable.md for more information.
    public func callAsFunction() {
        if let eventType {
            return function(eventType, data)
        }
    }
    
    /// The initializer.
    /// - Parameters:
    ///   - function: A closure to be run when a user interacts with a specific user interface element.
    ///   - eventType: An event type associated with the presentation.
    ///   - data: Model data associated with the presentation which is used by the closure.
    public init(function: @escaping (EventType, InterfaceActionData<DestinationType, ContentType>) -> Void, eventType: EventType? = nil, data: InterfaceActionData<DestinationType, ContentType>? = nil) {
        self.function = function
        self.eventType = eventType
        if let data {
            self.data = data
        }
    }
    
    public static func == (lhs: InterfaceAction, rhs: InterfaceAction) -> Bool {
        return lhs.id.uuidString == rhs.id.uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
