//
//  InteractorRequestMethod.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A type that represents whether an interactor request should be made using concurrency or not.
public enum InteractorRequestMethod {
    /// Represents an interactor request that should be made synchronously.
    case sync
    
    /// Represents an interactor request that should be made using concurrency.
    case async
}
