//
//  Datasourceable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// Generic closure to handle data source responses.
public typealias DatasourceResponseClosure<T: Hashable> = (_ result: Result<T, Error>) -> Void

/// This protocol represents a datasource interactor. These datasources can be used to provide items to a Destination's view interface.
public protocol Datasourceable<ResultData>: AnyObject, Interactable {
    
    /// An enum which defines types of actions for a particular Interactor.
    associatedtype ActionType: Hashable
        
    /// Tells the provider to start retrieval of the items. Once retrieved, the items should be provided via the ``itemsProvider`` publisher.
    func startItemsRetrieval()
    
    /// An object which receives status updates about items retrieval progress.
    var statusDelegate: DatasourceItemsProviderStatusDelegate? { get set }
    
    /// Items contained by the datasource.
    var items: [ResultData] { get set }
}

