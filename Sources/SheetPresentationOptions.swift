//
//  SheetPresentationOptions.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An options model used in conjunction with ``SheetPresentationType`` to customize UIKit and SwiftUI modal sheet presentations.
public struct SheetPresentationOptions {
    
#if canImport(UIKit)
    /// Options which configure a UIKit sheet presentation.
    public var uiKit: ControllerSheetPresentationOptions?
#endif

#if canImport(SwiftUI)
    /// Options which configure a SwiftUI sheet presentation.
    public var swiftUI: ViewSheetPresentationOptions?
#endif

#if canImport(UIKit)
    
    /// An initializer for UIKit sheets.
    /// - Parameter uiKit: Options which configure a UIKit sheet presentation.
    public init(uiKit: ControllerSheetPresentationOptions? = nil) {
        self.uiKit = uiKit
    }
#endif
    
#if canImport(SwiftUI)
    /// An initializer for SwiftUI sheets.
    /// - Parameter swiftUI: Options which configure a SwiftUI sheet presentation.
    public init(swiftUI: ViewSheetPresentationOptions? = nil) {
        self.swiftUI = swiftUI
    }
#endif
    
}
