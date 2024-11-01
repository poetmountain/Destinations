//
//  ViewSheetPresentationOptions.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A model providing configuration options for SwiftUI sheet presentations.
public struct ViewSheetPresentationOptions {
    /// An enum defining the presentation modes for a SwiftUI sheet presentation.
    public enum PresentationMode: String {
        /// A `View` presented as a sheet.
        case sheet
        
        /// A `View` presented fullscreen over the current content.
        case fullscreen
    }

    /// The presentation mode of the sheet.
    public var presentationMode: PresentationMode = .sheet
    
    /// Specifies detents to the be used for the sheet.
    public var presentationDetents: Set<PresentationDetent>?
    
    /// Specifies the content interaction mode of the sheet. This is useful if you have content which needs to scroll inside your sheet.
    public var contentInteractionMode: PresentationContentInteraction = .automatic
    
    /// Specifies whether a user can interact with the content behind the sheet.
    public var backgroundInteractionMode: PresentationBackgroundInteraction = .automatic
    
    /// The initializer.
    /// - Parameters:
    ///   - presentationMode: The presentation mode of the sheet.
    ///   - presentationDetents: Specifies detents to the be used for the sheet.
    ///   - contentInteractionMode: Specifies the content interaction mode of the sheet.
    ///   - backgroundInteractionMode: Specifies whether a user can interact with the content behind the sheet.
    public init(presentationMode: PresentationMode? = nil, presentationDetents: Set<PresentationDetent>? = nil, contentInteractionMode: PresentationContentInteraction? = nil, backgroundInteractionMode: PresentationBackgroundInteraction? = nil) {
        if let presentationMode {
            self.presentationMode = presentationMode
            self.presentationDetents = presentationDetents
            if let contentInteractionMode {
                self.contentInteractionMode = contentInteractionMode
            }
            if let backgroundInteractionMode {
                self.backgroundInteractionMode = backgroundInteractionMode
            }
        }
    }
}
