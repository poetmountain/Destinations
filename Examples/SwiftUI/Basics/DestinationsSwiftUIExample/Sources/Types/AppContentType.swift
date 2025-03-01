//
//  AppContentType.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

public enum AppContentType: ContentTypeable {
    case color(model: ColorViewModel)
    case colors(models: [ColorViewModel])
    case dynamicView(view: ContainerView<AnyView>)
    case count(value: Int)
    
    public var rawValue: String {
        switch self {
            case .color(_):
                return "color"
            case .colors(_):
                return "colors"
            case .dynamicView:
                return "dynamicView"
            case .count:
                return "count"
        }
    }
}

extension AppContentType: Equatable {
    public static func == (lhs: AppContentType, rhs: AppContentType) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}
