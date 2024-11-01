//
//  AsyncDatasourceable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a datasource Interactor actor. These datasources can be used to provide items to a Destination's view interface.
public protocol AsyncDatasourceable<ResultData>: Actor, AsyncInteractable {
        
    /// Tells the provider to start retrieval of the items. Once retrieved, the items array should be updated.
    func startItemsRetrieval() async
    
    /// An object which receives status updates about items retrieval progress.
    var statusDelegate: DatasourceItemsProviderStatusDelegate? { get set }
    
    /// Items contained by the datasource.
    var items: [ResultData] { get set }
    
}

public extension AsyncDatasourceable {
    nonisolated func perform(request: Request, completionClosure: DatasourceResponseClosure<[ResultData]>?) {
        
    }
}
