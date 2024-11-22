//
//  RouteDestinationType.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

public enum RouteDestinationType: RoutableDestinations {
    
    public var id: String { rawValue }

    case start
    case splitView
    case colorsList
    case colorDetail
    
    public var rawValue: String {
        switch self {
            case .start:
                return "start"
            case .splitView:
                return "splitView"
            case .colorsList:
                return "colorsList"
            case .colorDetail:
                return "colorDetail"
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


