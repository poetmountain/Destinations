//
//  RouteDestinationType.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

public enum RouteDestinationType: RoutableDestinations {
    
    public var id: String { rawValue }

    public static var allCases: [RouteDestinationType] {
        return [.start, .colorsList, .colorDetail, .home, .tabBar(tabs: []), .sheet]
    }
    
    case start
    case colorsList
    case colorDetail
    case home
    case tabBar(tabs: [AppTabType])
    case sheet
    case swiftUI
    
    public var rawValue: String {
        switch self {
            case .start:
                return "start"
            case .colorsList:
                return "colorsList"
            case .colorDetail:
                return "colorDetail"
            case .home:
                return "home"
            case .tabBar(_):
                return "tabBar"
            case .sheet:
                return "sheet"
            case .swiftUI:
                return "swiftUI"
        }
    }
    
    
}

extension RouteDestinationType: Equatable {
    public static func == (lhs: RouteDestinationType, rhs: RouteDestinationType) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}

extension RouteDestinationType: CustomStringConvertible {
    public var description : String {
        return self.rawValue
    }
}
