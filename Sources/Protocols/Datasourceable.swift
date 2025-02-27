//
//  Datasourceable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a datasource interactor. These datasources can be used to provide items to a Destination's view interface.
public protocol Datasourceable<Item>: SyncInteractable {
    
    associatedtype Item: Hashable
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: Hashable
    
    /// Tells the provider to start retrieval of the items.
    @available(*, deprecated, message: "This method is deprecated and will be removed in a future version. To start items retrieval for a datasource, please instead use Destinationable's prepareForPresentation() and call performInterfaceAction() with an interaction type which can initiate a retrieval request from the datasource. If you need to configure an interactor prior to making requests, please call the new prepareForRequests() method.")
    func startItemsRetrieval()
    
    /// An object which receives status updates about items retrieval progress.
    var statusDelegate: DatasourceItemsProviderStatusDelegate? { get set }
    
    /// Items contained by the datasource.
    var items: [Item] { get set }
}

public extension Datasourceable {
    @available(*, deprecated, message: "This method is deprecated and will be removed in a future version. To start items retrieval for a datasource, please instead use Destinationable's prepareForPresentation() and call performInterfaceAction() with an interaction type which can initiate a retrieval request from the datasource. If you need to configure an interactor prior to making requests, please call the new prepareForRequests() method.")
    public func startItemsRetrieval() {}
}
