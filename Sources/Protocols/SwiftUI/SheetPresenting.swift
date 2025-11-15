//
//  SheetPresenting.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a `View` that supports presenting a SwiftUI sheet via its ``SheetPresenter`` object.
///
/// To present a sheet using Destinations, simply have your `View` adopt this protocol, add a `ViewModifier` for the ``sheetPresenter`` (`.modifier(sheetPresenter)`), and present a Destination with a `presentationType` of `.sheet(type: .present)`.
@MainActor public protocol SheetPresenting: ViewDestinationInterfacing {

    /// The ``SheetPresenter`` object which handles the presentation of sheets.
    var sheetPresentation: SheetPresentation { get set }
    
    /// Presents a `View` in a sheet from the current interface.
    /// - Parameter sheet: A ``Sheetable`` model representing the `View` to present in a sheet.
    func presentSheet(sheet: any Sheetable)
    
    /// Dismisses a sheet that's currently presented.
    func dismissSheet()
    
    /// Returns a closure that is used by Destinations internally to trigger the system sheet dismissal.
    /// - Parameter destination: The Destination presenting this sheet.
    /// - Returns: The ``SheetDismissalClosure`` closure.
    func sheetDismissalClosure<Destination: ViewDestinationable>(destination: Destination) -> SheetDismissalClosure
}

public extension SheetPresenting {
    
    func presentSheet(sheet: any Sheetable) {
        DestinationsSupport.logger.log("Presenting sheet \(sheet.description)", level: .verbose)

        sheetPresentation.systemDismissalClosure = sheetDismissalClosure(destination: destination())
        sheetPresentation.updateSheet(sheet)

    }
    
    func dismissSheet() {
        
        if let sheetID = sheetPresentation.sheet?.destinationID {
            let options = SystemNavigationOptions(targetID: sheetID)
            destination().performSystemNavigationAction(navigationType: .dismissSheet, options: options)
        }
    }
    
    func sheetDismissalClosure<Destination: ViewDestinationable>(destination: Destination) -> SheetDismissalClosure {
        let closure = { [weak destination, weak sheetPresentation] in
            if let sheetID = sheetPresentation?.sheet?.destinationID {
                let options = SystemNavigationOptions(targetID: sheetID)
                destination?.performSystemNavigationAction(navigationType: .dismissSheet, options: options)
            }
        }
        
        return closure
    }

}
