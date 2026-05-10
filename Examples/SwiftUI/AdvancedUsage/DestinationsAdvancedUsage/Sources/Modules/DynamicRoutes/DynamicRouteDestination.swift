//
//  DynamicRouteDestination.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class DynamicRouteDestination: DestinationTypes, NavigatingViewDestinationable {

    typealias ViewType = DynamicRouteView
    typealias UserInteractionType = UserInteractions

    enum UserInteractions: String, UserInteractionTypeable {
        case navigate
    }

    enum InteractorType: InteractorTypeable {
    }

    let id = UUID()
    
    let type: Route = .dynamic
    
    var view: ViewType?
    
    var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    var groupInternalState: GroupDestinationInternalState = GroupDestinationInternalState<DestinationType, ContentType, TabType>()

    var selectedRoute: Route = .welcome
    
    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

    func handleNavigateTapped() {
        handleThrowable { [weak self] in
            guard let strongSelf = self else { return }
            
            try strongSelf.performAction(
                for: .navigate,
                content: .route(strongSelf.selectedRoute)
            )
        }
    }
}
