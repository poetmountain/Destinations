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
public protocol Datasourceable<Item>: SyncInteractable {
    
    /// This type represents the type of data model this datasource handles.
    associatedtype Item: Hashable
    
    /// Tells the datasource to start retrieval of the items.
    ///
    /// > Note: This method is deprecated and will be removed in a future version. To start the retrieval of items for a datasource, please instead use ``Destinationable``'s `prepareForPresentation()` and call `performInterfaceAction()` with an interaction type which can initiate a retrieval request. If you need to configure an Interactor prior to making requests, please call the new `prepareForRequests()` method.
    @available(*, deprecated, message: "This method is deprecated and will be removed in a future version. To start items retrieval for a datasource, please instead use Destinationable's prepareForPresentation() and call performInterfaceAction() with an interaction type which can initiate a retrieval request. If you need to configure an interactor prior to making requests, please call the new prepareForRequests() method.")
    func startItemsRetrieval()
    
    /// Items contained by the datasource.
    var items: [Item] { get set }
}

public extension Datasourceable {
    @available(*, deprecated, message: "This method is deprecated and will be removed in a future version. To start items retrieval for a datasource, please instead use Destinationable's prepareForPresentation() and call performInterfaceAction() with an interaction type which can initiate a retrieval request from the datasource. If you need to configure an interactor prior to making requests, please call the new prepareForRequests() method.")
    public func startItemsRetrieval() {}
}
