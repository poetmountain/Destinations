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
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    var systemNavigationConfigurations: NavigationConfigurations?

    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<SheetDestination>] = [:]


    var childWasRemovedClosure: GroupChildRemovedClosure?
    var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?
    
    var childDestinations: [any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>] = []
    var currentChildDestination: (any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>)?

    public var isSystemNavigating: Bool = false
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }
}
