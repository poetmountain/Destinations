//
//  AsyncInteractable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an Interactor actor. Interactors provide an interface to perform some business logic, often acting as a datasource by interfacing with an API, handling system APIs, or some other self-contained work.
public protocol AsyncInteractable<Request, ResultData>: Actor, Interactable {
    
    /// Requests the interactor to perform an async operation.
    /// - Parameter request: A configuration model which defines the request.
    /// - Returns: A `Result` containing an array of items.
    func perform(request: Request) async -> Result<[ResultData], Error>
}
