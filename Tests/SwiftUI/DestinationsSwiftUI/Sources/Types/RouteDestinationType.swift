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

public enum AppContentType: ContentTypeable {
    case color(model: ColorViewModel)
    case dynamicView(view: ContainerView<AnyView>)
    
    public var rawValue: String {
        switch self {
            case .color(_):
                return "color"
            case .dynamicView(_):
                return "dynamicView"
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

    case colorsList
    case colorDetail
    case home
    case dynamic
    case tabBar(tabs: [AppTabType])
    case splitView
    
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
            case .splitView:
                return "splitView"
        }
    }
}

extension RouteDestinationType: Equatable {
    public static func == (lhs: RouteDestinationType, rhs: RouteDestinationType) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}
