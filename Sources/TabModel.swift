//
//  TabModel.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A model that's used internally to represent tab types in Destinations.
public final class TabModel<TabType: TabTypeable>: Equatable, Hashable {
    
    /// A unique identifier.
    public let id = UUID()
    
    /// The type of tab.
    public let type: TabType
    
    /// The initializer.
    /// - Parameter type: A tab type.
    public init(type: TabType) {
        self.type = type
    }

    // for purposes of comparing tab types, only care about the type name
    public static func == (lhs: TabModel, rhs: TabModel) -> Bool {
        return lhs.type == rhs.type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension TabModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        "TabModel \(type)"
    }
}
