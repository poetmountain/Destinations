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
@MainActor public protocol ViewDestinationable<DestinationType, ContentType, TabType>: Destinationable where DestinationType: RoutableDestinations {
    
    /// The type of `View` associated with this Destination.
    associatedtype ViewType: ViewDestinationInterfacing
    
    /// The SwiftUI `View` associated with this Destination.
    var view: ViewType? { get set }
    
    /// Returns the View managed by this Destination.
    /// - Returns: A ``ViewDestinationInterfacing`` object, if one exists.
    func currentView() -> ViewType?

    /// Presents a sheet in the Destination's view.
    /// - Parameter sheet: The sheet model to configure the sheet presentation.
    /// - Returns: A boolean representing whether the sheet can successfully be presented.
    func presentSheet(sheet: any Sheetable) -> Bool
    
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
    
    @available(*, deprecated, renamed: "assignInteractor(_:to:)", message: "This method is deprecated and will be removed in a future version. Please migrate your code to use the `assignInteractor(_:to:)` method instead.")
    func assignInteractor<Request: InteractorRequestConfiguring>(interactor: any AbstractInteractable<Request>, for type: InteractorType) {
    
        internalState.interactors[type] = interactor

        configureInteractor(interactor, type: type)
        
    }
    
    func assignInteractor<Request: InteractorRequestConfiguring>(_ interactor: any AbstractInteractable<Request>, to type: InteractorType) {
        
        internalState.interactors[type] = interactor
        
    }
    
    func presentSheet(sheet: any Sheetable) -> Bool {
        
        guard let stateModel = stateModel as? any SheetPresenting else {
            DestinationsSupport.logger.log("Sheet presentation stopped. The state model attached to the Destination of type \(self.type) does not conform to the SheetPresenting protocol.", category: .error)
            return false
        }
        
        if stateModel.sheetPresentation.sheet == nil {
            stateModel.presentSheet(sheet: sheet)
            return true
        }
        
        DestinationsSupport.logger.log("Sheet presentation stopped; an existing sheet \(String(describing: stateModel.sheetPresentation.sheet?.id.uuidString)) is already presented.", category: .error)

        return false
    }
    
    func dismissSheet() {
        if let stateModel = stateModel as? any SheetPresenting {
            stateModel.sheetPresentation.dismissSheet()
        }
    }
    
    func updateInterfaceActions(actions: [InterfaceAction<EventType, DestinationType, ContentType>]) {
        for action in actions {
            if action.eventType != nil {
                handleThrowable { [weak self] in
                    try self?.addInterfaceAction(action: action)
                }

            }
        }
    }
    
    func updateSystemNavigationActions(actions: [InterfaceAction<SystemNavigationType, DestinationType, ContentType>]) {
        for action in actions {
            if action.eventType != nil {
                addSystemNavigationAction(action: action)
            }
        }
    }
    
    func performAction(for eventType: EventType, content: ContentType? = nil) throws {
        
        guard var interfaceAction = internalState.interfaceActions[eventType] else {
            let template = DestinationsSupport.errorMessage(for: .missingInterfaceAction(message: ""))
            let message = String(format: template, eventType.rawValue, type.rawValue)
            
            throw DestinationsError.missingInterfaceAction(message: message)
        }
        
        if let presentation = internalState.destinationConfigurations?.configuration(for: eventType) {
            
            if case .navigationStack(type: let navigationType) = presentation.presentationType, navigationType == .goBack {
                moveBackInNavigationStack()
                return
            }
            
            let assistant: (any InterfaceActionConfiguring<EventType, DestinationType, ContentType>)
            
            switch presentation.assistantType {
                case .basic:
                    assistant = DefaultPresentationAssistant<EventType, DestinationType, ContentType>()
                case .custom(let customAssistant):
                    if let customAssistant = customAssistant as? any InterfaceActionConfiguring<EventType, DestinationType, ContentType> {
                        assistant = customAssistant
                    } else {
                        let template = DestinationsSupport.errorMessage(for: .missingInterfaceActionAssistant(message: ""))
                        let message = String(format: template, self.type.rawValue)
                        throw DestinationsError.missingInterfaceActionAssistant(message: message)
                    }
            }
            
            let configuredAction = assistant.configure(interfaceAction: interfaceAction, eventType: eventType, destination: self, content: content)
            configuredAction()
            
        } else {
            // if no presentation was found, this is probably an action for an interactor
            interfaceAction.data.contentType = content
            interfaceAction()
        }
    }
    
    @available(*, deprecated, renamed: "performAction(for:content:)", message: "This method is deprecated and will be removed in a future version. Please migrate your code to use the `performAction(for:content:)` method instead.")
    func performInterfaceAction(eventType: EventType, content: ContentType? = nil) throws {
        try performAction(for: eventType, content: content)
    }

    func assignAssociatedView(view: ViewType) {
        self.view = view
        
        // assign the state from the View to the Destination
        if let viewModel = view.destinationState.stateModel as? any StateModeling<Self> {
            stateModel = viewModel
            stateModel?.destination = self
        } else {
            assertionFailure("The StateModel assigned to the View's destinationState is not of type StateModeling.")
        }
        
    }
    
    func removeAssociatedInterface() {
        view = nil
        stateModel?.destination = nil
        stateModel = nil
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

