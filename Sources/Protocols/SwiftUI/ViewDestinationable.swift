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
    
    associatedtype DestinationType: RoutableDestinations

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
            if let interactionType = action.userInteractionType {
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
    
    
    func performInterfaceAction(interactionType: UserInteractionType, content: ContentType? = nil) throws {
        
        guard var interfaceAction = internalState.interfaceActions[interactionType] else {
            let template = DestinationsSupport.errorMessage(for: .missingInterfaceAction(message: ""))
            let message = String(format: template, interactionType.rawValue, type.rawValue)
            
            throw DestinationsError.missingInterfaceAction(message: message)
        }
        
        if let presentation = internalState.destinationConfigurations?.configuration(for: interactionType) {
            
            if case .navigationStack(type: let navigationType) = presentation.presentationType, navigationType == .goBack {
                moveBackInNavigationStack()
                return
            }
            
            let assistant: (any InterfaceActionConfiguring<UserInteractionType, DestinationType, ContentType>)
            
            switch presentation.assistantType {
                case .basic:
                    assistant = DefaultActionAssistant<UserInteractionType, DestinationType, ContentType>()
                case .custom(let customAssistant):
                    if let customAssistant = customAssistant as? any InterfaceActionConfiguring<UserInteractionType, DestinationType, ContentType> {
                        assistant = customAssistant
                    } else {
                        let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                        let message = String(format: template, self.type.rawValue)
                        throw DestinationsError.missingInterfaceActionAssistant(message: message)
                    }
            }
            
            let configuredAction = assistant.configure(interfaceAction: interfaceAction, interactionType: interactionType, destination: self, content: content)
            configuredAction()
            
        } else {
            // if no presentation was found, this is probably an action for an interactor
            interfaceAction.data.contentType = content
            interfaceAction()
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

