//
//  SheetPresenter.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A closure used internally by Destinations to trigger the system sheet dismissal.
public typealias SheetDismissalClosure = () -> Void

/// This SwiftUI `ViewModifier` manages the presentation of a sheet.
public struct SheetPresenter: ViewModifier {

    /// Configures a SwiftUI sheet's presentation.
    @State public var sheetPresentation: any SheetPresentationConfiguring

    /// The SwiftUI sheet to present.
    public var sheet: (any Sheetable)? {
        return sheetPresentation.sheet
    }
    
    /// The initializer.
    /// - Parameter presentation: A model that configures a SwiftUI sheet's presentation.
    public init(presentation: any SheetPresentationConfiguring) {
        _sheetPresentation = State.init(initialValue: presentation)
    }
    
    @ViewBuilder func sheetContent(content: Content) -> some View {
        content

        .fullScreenCover(isPresented: $sheetPresentation.shouldPresentFullscreen) {
            self.sheetPresentation.systemDismissalClosure?()
            self.sheetPresentation.dismissedClosure?()
            self.sheetPresentation.removeCurrentSheet()
            
        } content: {
            self.sheetPresentation.sheet?.view
        }
        
        
        .sheet(isPresented: $sheetPresentation.shouldPresentSheet, onDismiss: {
            self.sheetPresentation.systemDismissalClosure?()
            self.sheetPresentation.dismissedClosure?()
            self.sheetPresentation.removeCurrentSheet()
            
        }, content: {
            self.sheetPresentation.sheet?.view
            .presentationDetents(sheetPresentation.presentationDetents)
            .presentationContentInteraction(sheetPresentation.contentInteractionMode)
            .presentationBackgroundInteraction(sheetPresentation.backgroundInteractionMode)
        })
        
    }
    
    /// A `View` body which presents the sheet.
    public func body(content: Content) -> some View {
        sheetContent(content: content)
    }
    
    /// Updates the sheet being presented.
    public func updateSheet(_ sheet: any Sheetable) {
        sheetPresentation.updateSheet(sheet)
    }
    
    /// Dismisses the sheet that's currently presented.
    public func dismissSheet() {
        sheetPresentation.shouldPresentSheet = false
        sheetPresentation.shouldPresentFullscreen = false
    }
    
}

public extension View {

    
    /// Provides a `ViewModifier` which can present a Destination as a sheet.
    /// - Parameter presentation: The configuration object for a sheet presentation.
    /// - Returns: The `View` which provides the sheet presentation.
    public func destinationSheet(presentation: SheetPresentation) -> some View {
        modifier(SheetPresenter(presentation: presentation))
    }

}
