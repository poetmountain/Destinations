//
//  StateModeling.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a state model associated with a Destination.
@MainActor public protocol StateModeling<Destination>: AnyObject {

    associatedtype Destination: Destinationable

    typealias EventType = Destination.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    /// The Destination associated with this state model.
    ///
    /// This property should be assigned by the View or UIViewController in the state model's initializer.
    var destination: Destination? { get set }
        
    /// Performs an action tied to the Destination event of the specified type.
    ///
    /// > Important: This method should not be called directly. When a user interaction is made on a View or UIViewController, please call the ``handleEvent(_:content:)`` method on the associated Destination instead.
    /// - Parameters:
    ///   - type: The interaction event type to act upon.
    ///   - content: An optional content model to use when performing the action.
    func handleEvent(_ type: EventType, content: ContentType?)

    /// Handles the result of an Interactor request in a synchronous context, forwarded from the Destination.
    /// - Parameters:
    ///    - result: The Result object containing data returned from the request.
    ///    - request: The original request used in this Interactor operation.
    func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request)
    
    /// Handles the result of an async Interactor request, forwarded from the Destination.
    /// - Parameters:
    ///    - result: The Result object containing data returned from the request.
    ///    - request: The original request used in this Interactor operation.
    func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async
    
    /// Implement this method in your StateModeling classes to put any initial state setup actions or datasource retrieval calls here that should only be run when a state model is first created.
    ///
    /// This method is called automatically when a Destination is presented by a Flow for the first time, but before its associated UI is built, and is forwarded to the state model. Unlike ``prepareForAppearance(isVisible:)``, this method is only called once.
    /// > Important: Do not call this method directly. This lifecycle method is called by the state model's associated Destination.
    func prepareForPresentation()

    /// Implement this method in your StateModeling classes to place any setup tasks that need to be run each time the Destination's UI element becomes active.
    ///
    /// This method is called automatically when a Destination is about to be presented by a Flow, prior to the associated UI element appearing on-screen, and is forwarded to the state model. This method is preferred and is often more reliable than using native UI hooks like `View`'s `onAppear` modifier in SwiftUI projects.
    /// > Important: Do not call this method directly. This lifecycle method is called by the state model's associated Destination.
    /// - Parameters:
    ///   - isVisible: Represents whether this state model's Destination will actually be visible on-screen when it is presented. If the Destination was presented within the middle of a Destination path presentation, it would be `false`. This is useful for instance if you wish to avoid calling setup tasks unless it is the final Destination in a path presentation.
    func prepareForAppearance(isVisible: Bool)

    /// This method is called automatically when a Destination is about to become inactive, and is forwarded to the state model. Implement this method in your StateModeling classes to place any teardown tasks that need to be run each time the Destination's UI element is no longer visible or the active element.
    ///
    /// This method is preferred and is often more reliable than using native UI hooks like `View`'s `onDisappear` modifier in SwiftUI projects, and especially in cases where several UI elements may be added in quick succession in a `NavigationStack`.
    /// > Important: Do not call this method directly. This lifecycle method is called by the state model's associated Destination.
    /// - Parameters:
    ///   - wasVisible: Represents whether the Destination which is disappearing was actually visible on-screen. If this Destination was presented within the middle of a Destination path presentation, it would be `false`.
    func prepareForDisappearance(wasVisible: Bool)

    /// Configures the Interactor that is assigned to the Destination associated with this state model. You may use this method to make any initial requests to the Interactor to set up the interface's initial state.
    ///
    /// > Important: Do not call this method directly. This lifecycle method is called automatically when an Interactor is assigned to the associated Destination.
    /// - Parameters:
    ///   - interactor: The Interactor to configure requests for.
    ///   - type: The type of interactor.
    func configureInteractor(_ interactor: any AbstractInteractable, type: InteractorType)
    
    /// When this method is called, the Destination is about to be removed from the Flow. Any resource references should be removed and in-progress interactor tasks should be stopped.
    func cleanupResources()
}

public extension StateModeling {
    func prepareForPresentation() {}
    
    func prepareForAppearance(isVisible: Bool) {}

    func prepareForDisappearance(wasVisible: Bool) {}

    func configureInteractor(_ interactor: any AbstractInteractable, type: InteractorType) {}
    
    // default implementation
    func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) {
        DestinationsSupport.logger.log("Calling default handleInteractorResult method implementation for \(request) because one was not found on the state model for Destination type \(self.destination?.type).", category: .error)
    }
    
    // default implementation
    func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async {
        DestinationsSupport.logger.log("Calling default handleAsyncInteractorResult method implementation for \(request) because one was not found on the state model for Destination type  \(self.destination?.type).", category: .error)
    }
    
    func cleanupResources() {}
}
