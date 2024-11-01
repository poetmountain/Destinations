//
//  InteractorRequestMethod.swift
//  Destinations
//
//  Created by Brett Walker on 10/24/24.
//

import Foundation

/// A type that represents whether an interactor request should be made using concurrency or not.
public enum InteractorRequestMethod {
    /// Represents an interactor request that should be made synchronously.
    case sync
    
    /// Represents an interactor request that should be made using concurrency.
    case async
}
