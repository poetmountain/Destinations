//
//  ActionPerformableCollection.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines a collection of ``ActionPerformable`` objects that can be run together, such as a sequence or group.
///
/// Conforming types manage an ordered or grouped set of actions sharing the same `ContentType`, and are responsible for performing them and accumulating their results into an ``ActionCollectionResults`` object.
public protocol ActionPerformableCollection<ContentType>: ActionPerformable {
    
    /// Adds an action to the collection.
    ///
    /// - Parameter action: The ``ActionPerformable`` object to add to this collection.
    /// - Throws: ``ActionError/invalidConfiguration`` if the action is not compatible with this collection.
    func add(action: any ActionPerformable<ContentType>) throws(ActionError<ContentType>)
}
