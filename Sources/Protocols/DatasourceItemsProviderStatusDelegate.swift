//
//  DatasourceItemsProviderStatusDelegate.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a delegate object that provides status updates during the retrieval of items by a ``Datasourceable`` object.
public protocol DatasourceItemsProviderStatusDelegate: AnyObject {
    
    /// This method should be called when a ``Datasourceable`` object has updated its items.
    /// - Parameter result: A Result object containing updated items.
    func didUpdateItems<I>(with result: Result<I, Error>)
}

