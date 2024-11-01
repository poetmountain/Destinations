//
//  DynamicDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Destinations
import SwiftUI

public final class DynamicDestination: DestinationTypes, ViewDestinationable {
        
    public typealias ViewType = DynamicView<AnyView>
    public typealias UserInteractionType = UserInteractions

    public enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
    }

    public let id = UUID()

    public lazy var type: RouteDestinationType = .dynamic

    public var view: ViewType?

    public var parentDestinationID: UUID?

    public var destinationConfigurations: DestinationConfigurations?
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractions : any InteractorAssisting<DynamicDestination>] = [:]

    public var isSystemNavigating: Bool = false


    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }

}
