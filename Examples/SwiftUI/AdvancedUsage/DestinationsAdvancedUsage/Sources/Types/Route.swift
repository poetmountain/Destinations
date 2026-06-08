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
enum Route: String, RoutableDestinations, Identifiable {

    var id: String { rawValue }

    case dynamic
    case welcome
    case info

}

extension Route: Equatable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}
