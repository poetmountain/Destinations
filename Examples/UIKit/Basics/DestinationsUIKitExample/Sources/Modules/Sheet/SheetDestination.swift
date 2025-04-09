//
//  SheetDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

final class SheetDestination: NavigatingControllerDestinationable, DestinationTypes {

    typealias UserInteractionType = SheetViewController.UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationType, AppContentType, TabType>
    typealias ControllerType = SheetViewController
    
    public let id = UUID()
    
    public let type: RouteDestinationType = .sheet
    
    public var controller: ControllerType?
    
    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, AppContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, AppContentType, TabType> = GroupDestinationInternalState()


    public var isSystemNavigating: Bool = false
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        internalState.parentDestinationID = parentDestination
        internalState.destinationConfigurations = destinationConfigurations
        internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    func prepareForPresentation() {
    }
}
