//
//  Sheetable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This protocol represents a model used for presenting a SwiftUI sheet element.
public protocol Sheetable: Identifiable {
    
    /// A unique identifier.
    var id: UUID { get }
    
    /// A unique identifier of the associated Destination being presented.
    var destinationID: UUID { get set }
    
    /// An options object that configures how the sheet is presented.
    var options: ViewSheetPresentationOptions? { get set }
    
    /// The `View` to be presented in the sheet.
    var view: ContainerView<AnyView> { get set }

    /// A debugging description.
    var description: String { get }
}
