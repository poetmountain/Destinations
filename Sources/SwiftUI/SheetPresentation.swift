//
//  SheetPresentation.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// Configures the presentation of a SwiftUI sheet.
@Observable
public final class SheetPresentation: SheetPresentationConfiguring {
 
    public var id: UUID = UUID()
        
    public var sheet: (any Sheetable)?
    
    public var dismissalClosure: SheetDismissalClosure?
    
    public var shouldPresentSheet = false
    
    public var shouldPresentFullscreen = false
    
    public var presentationMode: ViewSheetPresentationOptions.PresentationMode = .sheet
    
    public var presentationDetents: Set<PresentationDetent> = []
    
    public var contentInteractionMode: PresentationContentInteraction = .automatic
    
    public var backgroundInteractionMode: PresentationBackgroundInteraction = .automatic
    
    /// The initializer.
    /// - Parameters:
    ///   - sheet: The sheet model to present.
    ///   - dismissalClosure: A closure to be run when a sheet is dismissed.
    public init(sheet: (any Sheetable)? = nil, dismissalClosure: SheetDismissalClosure? = nil) {
        if let sheet {
            self.sheet = sheet
        }
        self.dismissalClosure = dismissalClosure
    }
    
    /// Provides a new sheet
    /// - Parameter sheet: A new sheet to be presented.
    public func updateSheet(_ sheet: (any Sheetable)) {
        self.sheet = sheet
        if let options = sheet.options {
            presentationMode = options.presentationMode
            switch options.presentationMode {
                case .sheet:
                    shouldPresentFullscreen = false
                    shouldPresentSheet = true
                case .fullscreen:
                    shouldPresentFullscreen = true
                    shouldPresentSheet = false
            }
            if let presentationDetents = options.presentationDetents {
                self.presentationDetents = presentationDetents
            }
            self.contentInteractionMode = options.contentInteractionMode
            self.backgroundInteractionMode = options.backgroundInteractionMode
        }
    }
    
    /// Dismisses the current sheet.
    public func dismissSheet() {
        shouldPresentSheet = false
        shouldPresentFullscreen = false
    }
    
    /// Removes the current sheet, resetting this object to a default state.
    public func removeCurrentSheet() {
        self.sheet = nil
        shouldPresentSheet = false
        shouldPresentFullscreen = false
        presentationDetents = []
        contentInteractionMode = .automatic
        backgroundInteractionMode = .automatic
        dismissalClosure = nil
    }

    
    public static func == (lhs: SheetPresentation, rhs: SheetPresentation) -> Bool {
        lhs.id == rhs.id
    }
    
}
