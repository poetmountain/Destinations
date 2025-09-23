//
//  ViewDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This protocol represents a Destination which is associated with a SwiftUI `View`.
@MainActor public protocol ViewDestinationable<DestinationType, ContentType, TabType>: Destinationable {
    
    /// The type of `View` associated with this Destination.
    associatedtype ViewType: ViewDestinationInterfacing

    /// The SwiftUI `View` associated with this Destination.
    var view: ViewType? { get set }
    
    /// Returns the View managed by this Destination.
    /// - Returns: A ``ViewDestinationInterfacing`` object, if one exists.
    func currentView() -> ViewType?

    /// Presents a sheet in the Destination's view.
    /// - Parameter sheet: The sheet model to configure the sheet presentation.
    func presentSheet(sheet: any Sheetable)
    
    /// Dismisses the currently presented sheet.
    func dismissSheet()
    
    /// Assigns a `View` to be associated with this Destination.
    /// - Parameter view: The `View` that should be represented by this Destination.
    func assignAssociatedView(view: ViewType)
}

public extension ViewDestinationable {
    
    func currentView() -> ViewType? {
        return view
    }
    
    func assignInteractor<Request: InteractorRequestConfiguring>(interactor: any AbstractInteractable<Request>, for type: InteractorType) {
    
        internalState.interactors[type] = interactor

        configureInteractor(interactor, type: type)
        
    }
    
    func presentSheet(sheet: any Sheetable) {
        
        if let view = view as? any SheetPresenting {
            view.presentSheet(sheet: sheet)
        }
        
    }
    
    func dismissSheet() {
        if let view = view as? any SheetPresenting {
            view.sheetPresentation.dismissSheet()
        }
    }
    
    func updateInterfaceActions(actions: [InterfaceAction<UserInteractionType, DestinationType, ContentType>]) {
        for action in actions {
            if let action = action as? InterfaceAction<UserInteractionType, DestinationType, ContentType>, let interactionType = action.userInteractionType {
                handleThrowable { [weak self] in
                    try self?.addInterfaceAction(action: action)
                }

            }
        }
    }
    
    func updateSystemNavigationActions(actions: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>]) {
        for action in actions {
            if let action = action as? InterfaceAction<SystemNavigationType, DestinationType, ContentType>, let interactionType = action.userInteractionType {
                addSystemNavigationAction(action: action)
            }
        }
    }

    func assignAssociatedView(view: ViewType) {
        DestinationsSupport.logger.log("assign view for \(type)")
        self.view = view
    }
    
    func removeAssociatedInterface() {
        DestinationsSupport.logger.log("remove view for \(type)")
        self.view = nil
    }
}

