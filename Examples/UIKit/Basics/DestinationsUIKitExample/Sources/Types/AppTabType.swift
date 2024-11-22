//
//  AppTabType.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

public enum AppTabType: String, TabTypeable {
    case palettes
    case home
    case swiftUI
    
    public var tabName: String {
        switch self {
            case .palettes:
                return "Palettes"
            case .home:
                return "Home"
            case .swiftUI:
                return "SwiftUI"
        }
    }

}
