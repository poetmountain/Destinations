//
//  Sheet.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A model used for presenting a SwiftUI sheet element.
public struct Sheet: Sheetable {
    
    /// A unique identifier.
    public let id = UUID()
    
    /// A unique identifier of the associated Destination being presented.
    public var destinationID: UUID
    
    /// The `View` to be presented in the sheet.
    public var view: ContainerView<AnyView>
    
    /// An options model which configures a SwiftUI sheet for presentation.
    public var options: ViewSheetPresentationOptions?
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationID: A unique identifier of the associated Destination being presented.
    ///   - view: The `View` to be presented in the sheet.
    ///   - options: An options model which configures a SwiftUI sheet for presentation.
    public init(destinationID: UUID, view: ContainerView<AnyView>, options: ViewSheetPresentationOptions? = nil) {
        self.destinationID = destinationID
        self.view = view
        self.options = options
    }

    public var description: String {
        return "\(Self.self) : \(id) : options: \(options)"
    }
}
