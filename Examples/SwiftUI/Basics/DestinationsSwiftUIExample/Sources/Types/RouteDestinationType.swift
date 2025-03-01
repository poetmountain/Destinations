//
//  RouteDestinationType.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import SwiftUI
import Destinations



public enum RouteDestinationType: RoutableDestinations, CaseIterable {

    public var id: String { rawValue }

    public static var allCases: [RouteDestinationType] {
        return [.colorsList, .colorDetail, .home, .dynamic, .tabBar(tabs: []), .counter]
    }
    
    case colorsList
    case colorDetail
    case home
    case dynamic
    case tabBar(tabs: [AppTabType])
    case counter
    
    public var rawValue: String {
        switch self {
            case .colorsList:
                return "colorsList"
            case .colorDetail:
                return "colorDetail"
            case .home:
                return "home"
            case .dynamic:
                return "dynamic"
            case .tabBar(_):
                return "tabBar"
            case .counter:
                return "counter"
        }
    }
}

extension RouteDestinationType: Equatable {
    public static func == (lhs: RouteDestinationType, rhs: RouteDestinationType) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}
