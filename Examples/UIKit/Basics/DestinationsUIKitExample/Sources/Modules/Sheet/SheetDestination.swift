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

    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias UserInteractionType = SheetViewController.UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    typealias ControllerType = SheetViewController
    
    public let id = UUID()
    
    public let type: RouteDestinationType = .sheet
    
    public var controller: ControllerType?
    
    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<PresentationType, PresentationConfiguration> = GroupDestinationInternalState()


    public var isSystemNavigating: Bool = false
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        internalState.parentDestinationID = parentDestination
        internalState.destinationConfigurations = destinationConfigurations
        internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    func prepareForPresentation() {
    }
}
