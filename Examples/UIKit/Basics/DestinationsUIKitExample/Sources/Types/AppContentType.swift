//
//  AppContentType.swift
//  DestinationsUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

enum AppContentType: ContentTypeable {
    
    case color(model: ColorViewModel)
    case colors(model: [ColorViewModel])
    case colorsRequest(request: ColorsRequest)
    
    var rawValue: String {
        switch self {
            case .color:
                return "color"
            case .colors:
                return "colors"
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
