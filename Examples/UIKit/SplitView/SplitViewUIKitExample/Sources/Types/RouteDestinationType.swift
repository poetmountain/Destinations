//
//  RouteDestinationType.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

enum AppContentType: ContentTypeable {
    
    case color(model: ColorViewModel)
    case colorsRequest(request: ColorsRequest)
    
    var rawValue: String {
        switch self {
            case .color:
                return "color"
            case .colorsRequest:
                return "colorsRequest"
        }
    }
}

extension AppContentType: Equatable {
    public static func == (lhs: AppContentType, rhs: AppContentType) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}

public enum RouteDestinationType: RoutableDestinations {
    
    public var id: String { rawValue }

    case start
    case splitView
    case swiftUI
    case colorsList
    case colorNav
    case colorDetail
    
    public var rawValue: String {
        switch self {
            case .start:
                return "start"
            case .splitView:
                return "splitView"
            case .swiftUI:
                return "swiftUI"
            case .colorsList:
                return "colorsList"
            case .colorNav:
                return "colorNav"
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

