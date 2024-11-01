//
//  ActionAssistantType.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This enum represents the type of assistant to be used in configuring an ``InterfaceAction`` object.
public enum ActionAssistantType {
    
    /// The basic assistant type, a ``DefaultActionAssistant`` assistant. This type is adequate to present Destinations without passing model state.
    case basic
    
    /// This type passes a custom assistant, used for configuring more advanced presentation needs such as passing along models or handling custom Destination types.
    case custom(_ assistant: any InterfaceActionConfiguring)
}
