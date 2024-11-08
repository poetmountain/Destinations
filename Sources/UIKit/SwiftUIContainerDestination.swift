//
//  SwiftUIContainerDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A Destination representing a ``SwiftUIContainerController`` instance which presents a SwiftUI `View` within UIKit.
public final class SwiftUIContainerDestination<Content: SwiftUIHostedInterfacing, PresentationConfiguration: DestinationPresentationConfiguring>: ControllerDestinationable {
    
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    public typealias InteractorType = Content.InteractorType
    public typealias PresentationConfiguration = PresentationConfiguration
    public typealias DestinationType = PresentationConfiguration.DestinationType
    public typealias TabType = PresentationConfiguration.TabType
    public typealias ContentType = PresentationConfiguration.ContentType
    public typealias UserInteractionType = Content.UserInteractionType
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    public typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    public typealias ControllerType = SwiftUIContainerController<Content>
    
    /// The type of `View` contained within this Destination.
    public typealias ViewType = Content

    public let id = UUID()
    
    public let type: DestinationType
    
    public var controller: ControllerType?

    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    public var systemNavigationConfigurations: NavigationConfigurations?

    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType : any InteractorAssisting<SwiftUIContainerDestination<Content, PresentationConfiguration>>] = [:]
    
    public var isSystemNavigating: Bool = false
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.type = destinationType
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }

    public func cleanupResources() {
        controller?.cleanupResources()
    }
}

