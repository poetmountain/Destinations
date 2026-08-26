//
//  DestinationsError.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An enum representing Destinations errors that can be thrown.
public enum DestinationsError: Error, Hashable {
    
    /// An error type sent when a tab is not found.
    ///
    /// - Parameter message: A message to be sent with the error.
    case tabNotFound(message: String)
    
    /// An error type sent when an interactor is not found.
    ///
    /// - Parameter message: A message to be sent with the error.
    case interactorNotFound(message: String)
    
    /// An error type sent when the child Destination of a ``GroupedDestinationable`` class was not found.
    ///
    /// - Parameter message: A message to be sent with the error.
    case childDestinationNotFound(message: String)
    
    /// An error type representing an unsupported action type for an interactor request.
    ///
    /// - Parameter message: A message to be sent with the error.
    case unsupportedInteractorActionType(message: String)
    
    /// An error type representing a missing interactor type.
    ///
    /// - Parameter message: A message to be sent with the error.
    case missingInteractorType(message: String)
    
    /// An error type denoting that an appropriate ``InterfaceAction`` was not found.
    ///
    /// - Parameter message: A message to be sent with the error.
    case missingInterfaceAction(message: String)
    
    /// An error type representing an unsupported Interactor assistant type for an interactor request.
    ///
    /// - Parameter message: A message to be sent with the error.
    case unsupportedInteractorAssistantType(message: String)
    
    /// An error type denoting that an assistant for performing an ``InterfaceAction`` is missing.
    ///
    /// - Parameter message: A message to be sent with the error.
    case missingInterfaceActionAssistant(message: String)
    
    /// An error type denoting that an async assistant did not implement the `asyncRequest` method.
    ///
    /// - Parameter message: A message to be sent with the error.
    case missingAsyncRequestImplementation(message: String)
    
    /// An error type denoting that a Destination type was not supplied with a presentation type that requires one.
    ///
    /// - Parameter message: A message to be sent with the error.
    case undefinedDestinationType(message: String)
    
    /// An error type denoting that a column type for the UIKit or SwiftUI split view interface is undefined.
    ///
    /// - Parameter message: A message to be sent with the error.
    case undefinedSplitViewColumnType(message: String)
    
    /// An error type generated when a duplicate event type is attempted to be used to add a ``InterfaceAction`` to a Destination.
    ///
    /// - Parameter message: A message to be sent with the error.
    case duplicateEventTypeUsed(message: String)
    
    /// An error type generated when an ActionConfiguration is sent to ``Destinationable/performActions(configuration:content:)-1nsw5`` that references an Interactor type that has not been registered with the Destination.
    ///
    /// - Parameter message: A message to be sent with the error.
    case unregisteredInteractor(message: String)
    
    /// An error type generated when an incompatible type was passed as a parameter, typically an incorrect sub-protocol.
    ///
    /// - Parameter message: A message to be sent with the error.
    case incompatibleType(message: String)
    
}
