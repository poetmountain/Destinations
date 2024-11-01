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
    
    
    public var tabName: String {
        switch self {
            case .palettes:
                return "Colors"
            case .home:
                return "Home"
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
        }
    }

}
