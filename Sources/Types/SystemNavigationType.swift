//
//  SystemNavigationType.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Defines types used for communicating system navigation events.
public enum SystemNavigationType: UserInteractionTypeable {

    /// Represents a system navigation event where a navigation stack interface is transitioning to the previous view in the stack.
    case navigateBackInStack
    
    /// Represents a system navigation event where a sheet is being dismissed.
    case dismissSheet

    public var rawValue: String {
        switch self {
            case .navigateBackInStack:
                return "navigateBackInStack"
            case .dismissSheet:
                return "dismissSheet"
        }
    }
}
