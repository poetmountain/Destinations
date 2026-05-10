//
//  Route.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@AutoCaseIterable
public enum Route: String, RoutableDestinations, Identifiable {

    public var id: String { rawValue }

    case dynamic
    case welcome
    case info

}

extension Route: Equatable {
    public static func == (lhs: Route, rhs: Route) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}
