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

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

    public func prepareForPresentation() {
    }
}
