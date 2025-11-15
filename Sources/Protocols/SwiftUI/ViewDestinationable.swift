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
    
    /// Sets a reference to the navigator presenting this Destination.
    /// - Parameter navigator: A navigator object.
    func setPresentingNavigator(navigator: any DestinationPathNavigating)
    
    /// Requests that the navigator presenting this Destination move to the previous Destination in the navigation path.
    func moveBackInNavigationStack()    
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
        self.view = view
    }
    
    func removeAssociatedInterface() {
        self.view = nil
    }
    
    func setPresentingNavigator(navigator: any DestinationPathNavigating) {
        internalState.navigator = navigator
    }
    
    func moveBackInNavigationStack() {
        guard let navigator = internalState.navigator else {
            DestinationsSupport.logger.log("Attempted to navigate back in stack, but no containing navigator was found.", category: .error, level: .error)
            return
        }
        
        var options: SystemNavigationOptions?
        if let targetID = navigator.previousPathElement() {
            options = SystemNavigationOptions(targetID: targetID)
        } else if let parentID = parentDestinationID() {
            options = SystemNavigationOptions(targetID: parentID)
        } else {
            options = SystemNavigationOptions(targetID: self.id)
        }
        
        performSystemNavigationAction(navigationType: SystemNavigationType.navigateBackInStack, options: options)
    }

}

