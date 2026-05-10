//
//  Datasourceable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a datasource Interactor. Datasources are designed to provide data models to a Destination based on requests, such as requesting objects from a server for display in a navigation stack. For more information on Interactors, please see the documentation for ``Interactable``.
///
/// > Note: If you need your datasource Interactor to run in an async context, please instead conform it to the ``AsyncDatasourceable`` protocol.
public protocol Datasourceable<Item>: Interactable {
    
    /// This type represents the type of data model this datasource handles.
    associatedtype Item: Hashable
    
    /// Items contained by the datasource.
    var items: [Item] { get set }
}
