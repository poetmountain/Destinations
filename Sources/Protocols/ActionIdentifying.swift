//
//  ActionIdentifying.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

/// This protocol represents a type which can be used to identify an ``ActionPerformable`` object.
///
/// Providing a type for steps is optional, but useful when a sequence contains multiple steps whose results share the same content type. For example, two network requests of different API endpoints may return the same model and you need to handle them differently. `String` conforms to this protocol out of the box, or you can conform your own enum for type-safe lookups.
///
/// > Note: Step types are not required to be unique. Looking up results by type returns all matching results.
public protocol ActionIdentifying: Hashable, Sendable {}

extension String: ActionIdentifying {}
