//
//  DestinationsSupport.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A singleton object which contains global options and an internal logger for Destinations. If you wish to interact with this class, please use the `shared` reference.
@MainActor public final class DestinationsSupport {
    
    /// Logger used for Destinations debug log entries.
    public static let logger: PMLogger = PMLogger()
    
    /// A singleton reference. Any interactions with this class should be through this instance.
    public static var shared: DestinationsSupport {
        return DestinationsSupport()
    }
    
    /// Determines whether Destinations should output debug statements.
    public var shouldShowDebugStatements = false {
        didSet {
            Self.logger.shouldOutputLogEntries = shouldShowDebugStatements
        }
    }
    
    /// Logs a Destinations error.
    public static func logError(error: Error) {
        switch error {
            case DestinationsError.tabNotFound(message: let message),
                DestinationsError.interactorNotFound(message: let message),
                DestinationsError.childDestinationNotFound(message: let message),
                DestinationsError.unsupportedInteractorActionType(message: let message),
                DestinationsError.missingInterfaceAction(message: let message),
                DestinationsError.missingInterfaceActionAssistant(message: let message),
                DestinationsError.duplicateUserInteractionTypeUsed(message: let message):
                
                DestinationsSupport.logger.log(message, category: .error)
                
            default:
                DestinationsSupport.logger.log("\(error.localizedDescription)", category: .error)
        }
    }
    
    
    /// Returns an error message for the specified ``DestinationsError`` type.
    /// - Parameter error: The ``DestinationsError`` type to create a message for.
    /// - Returns: An error message.
    public static func errorMessage(for error: DestinationsError) -> String {
        
        switch error {
            case .tabNotFound(_):
                return "Tried to update the selected tab type to %@, but it doesn't exist in the active tabs."
                
            case .interactorNotFound(_):
                return "Error: The requested interactor %@ was not found."
                
            case .childDestinationNotFound(message: _):
                return "Error: Could not find child Destination of type %@."
                
            case .unsupportedInteractorActionType(_):
                return "Error: Unsupported interactor action type."
                
            case .missingInterfaceAction(_):
                return "Error: No appropriate InterfaceAction was found while trying to perform a \"%@\" InterfaceAction from Destination %@."
                
            case .missingInterfaceActionAssistant(_):
                return "Error: No interactor assistant was found while constructing Interface action closure for type %@."
                
            case .undefinedSplitViewColumnType(message: _):
                return "Error: A column type for %@ was undefined in a SplitViewColumn model."
                
            case .duplicateUserInteractionTypeUsed(message: _):
                return "Error: An existing InterfaceAction already exists for the \"%@\" user interaction type."
                
            case .incompatibleType(message: _):
                return "Error: An incompatible type %@ was passed in as a parameter."
        }
    }
}
