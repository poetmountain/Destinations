//
//  HomeUserInteractions.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

enum HomeUserInteractions: UserInteractionTypeable {
    case replaceView
    case pathPresent
    
    var rawValue: String {
        switch self {
            case .replaceView:
                return "replaceView"
            case .pathPresent:
                return "pathPresent"
        }
    }
}
