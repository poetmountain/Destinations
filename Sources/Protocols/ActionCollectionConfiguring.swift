//
//  ActionCollectionConfiguring.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that represents the configuration for a collection of ``Action`` objects, either a group of actions running in parallel, or a sequence of actions running in serial order.
///
/// Types conforming to this protocol hold multiple ``ActionConfiguring`` child configurations under one umbrella. When ``ActionGroup/perform(with:sequenceOutputs:)`` is called on an ``ActionPerformableCollection`` object, it runs the child actions. If this object is an ``ActionGroup``, the results are then merged by the ``merger`` object into a single `ContentType` value, which the group's output conduit passes on to the next step in the sequence, if one exists.
///
/// ``ActionGroupConfiguration`` is the primary concrete conforming type.
public protocol ActionCollectionConfiguring<InteractorType, ContentType>: ActionConfiguring {
    
    /// The child action configurations that the group runs in parallel.
    var actions: [any ActionConfiguring<InteractorType, ContentType>] { get }
    
    /// Identifies whether this configuration represents a group or a standalone action.
    var configurationType: ActionConfigurationType { get }
    
    /// An object that merges the parallel child action results into a single `ContentType` value passed on through the group's output conduit. Required for the group to participate in the sequence. This property is unused in sequences.
    var merger: (any ActionResultsMerging<ContentType>)? { get }

    /// Determines whether a group's children are included in the `.group(results:)` origin recorded alongside its merged result. This property is unused in sequences.
    var shouldSaveChildResults: Bool { get }

}
