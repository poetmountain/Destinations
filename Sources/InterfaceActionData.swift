//
//  InterfaceActionData.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A model which provides data for an interface action to configure a presentation.
public struct InterfaceActionData<DestinationType: RoutableDestinations, ContentType: ContentTypeable> {
    /// The type of Destination.
    public var destinationType: DestinationType?
    
    /// A content type.
    public var contentType: ContentType?
    
    /// The type of presentation action.
    public var actionType: DestinationActionType?
    
    /// The identifier of the parent Destination.
    public var parentID: UUID?
    
    /// The identifier of the currently presented Destination.
    public var currentDestinationID: UUID?
    
    /// The identifier of the target Destination for this presentation.
    public var actionTargetID: UUID?
    
    /// The identifier of the presentation configuration model associated with this action.
    public var presentationID: UUID?
    
}
