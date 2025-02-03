//
//  ColorDetailDestination.swift
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorNavDestination: NavigatingViewDestinationable, DestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable {
        case color

        var rawValue: String {
            switch self {
                case .color:
                    return "color"

            }
        }
        
        static func == (lhs: UserInteractions, rhs: UserInteractions) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias UserInteractionType = UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>
    
    typealias ViewType = ColorNavView

    public let id = UUID()
    
    public let type: RouteDestinationType = .colorNav
    
    public var view: ViewType?
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    var systemNavigationConfigurations: NavigationConfigurations?

    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<ColorNavDestination>] = [:]

    var childDestinations: [any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>] = []
    var currentChildDestination: (any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>)?

    var childWasRemovedClosure: Destinations.GroupChildRemovedClosure?
    
    var currentDestinationChangedClosure: Destinations.GroupCurrentDestinationChangedClosure?
    
    
    public var isSystemNavigating: Bool = false
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }


}
