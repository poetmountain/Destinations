//
//  AppTabType.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

public enum AppTabType: String, TabTypeable {
 
    case palettes
    case home
    case counter
    
    
    public var tabName: String {
        switch self {
            case .palettes:
                return "Colors"
            case .home:
                return "Home"
            case .counter:
                return "Counter"
        }
    }
    
    /// An optional Image to use for the tab icon.
    public var image: Image {
        Image(uiImage: UIImage(ciImage: .empty()))
    }
    
    /// An optional image name to use for the tab icon.
    public var imageName: String {
        switch self {
            case .palettes:
                "paintpalette"
            case .home:
                "house"
            case .counter:
                "plus.arrow.trianglehead.clockwise"
        }
    }

}
