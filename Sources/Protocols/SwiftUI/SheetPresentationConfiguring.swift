//
//  SheetPresentationConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This protocol configures the presentation of a SwiftUI sheet.
public protocol SheetPresentationConfiguring: Identifiable, Equatable {

    /// A unique identifier.
    var id: UUID { get }
    
    /// Model data for the sheet being presented.
    var sheet: (any Sheetable)? { get set }
    
    /// A Boolean which determines whether the sheet should be presented.
    var shouldPresentSheet: Bool { get set }
    
    /// A Boolean which determines whether the sheet should be presented as fullscreen.
    var shouldPresentFullscreen: Bool { get set }
    
    /// The presentation mode of the sheet.
    var presentationMode: ViewSheetPresentationOptions.PresentationMode { get set }
    
    /// Specifies detents to the be used for the sheet.
    var presentationDetents: Set<PresentationDetent> { get set }
    
    /// Specifies the content interaction mode of the sheet. This is useful if you have content which needs to scroll inside your sheet.
    var contentInteractionMode: PresentationContentInteraction { get set }
    
    /// Specifies whether the user can interact with content behind the presented sheet.
    var backgroundInteractionMode: PresentationBackgroundInteraction { get set }
    
    /// A closure to be run when a sheet is dismissed.
    var dismissalClosure: SheetDismissalClosure? { get set }

    /// Provides a new sheet.
    /// - Parameter sheet: A new sheet to be presented.
    func updateSheet(_ sheet: any Sheetable)
    
    /// Dismisses the current sheet.
    func dismissSheet()
    
    /// Removes the current sheet, resetting this object to a default state.
    func removeCurrentSheet()
}
