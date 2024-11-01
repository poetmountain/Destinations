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
    
    /// An error type denoting that an appropriate ``InterfaceAction`` was not found.
    ///
    /// - Parameter message: A message to be sent with the error.
    case missingInterfaceAction(message: String)
    
    /// An error type representing that an assistant for performing an ``InterfaceAction`` is missing.
    ///
    /// - Parameter message: A message to be sent with the error.
    case missingInterfaceActionAssistant(message: String)
    
    /// An error type generated when a duplicate user interaction type is attempted to be used to add a ``InterfaceAction`` to a Destination.
    ///
    /// - Parameter message: A message to be sent with the error.
    case duplicateUserInteractionTypeUsed(message: String)
    
}
