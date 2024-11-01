//
//  TabTypeable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol representing an enum which defines tabs for a tab bar interface.
public protocol TabTypeable: Hashable, CaseIterable, Equatable where AllCases: RandomAccessCollection {
        
    /// The name of the tab.
    var tabName: String { get }
}


