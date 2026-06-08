//
//  AppContentType.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

enum AppContentType: ContentTypeable {
    case route(Route)
    
    var rawValue: String {
        switch self {
            case .route(_):
                "route"
        }
    }
}
