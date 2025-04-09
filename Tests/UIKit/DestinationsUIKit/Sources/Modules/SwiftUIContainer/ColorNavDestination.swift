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
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationType, AppContentType, TabType>
    
    typealias ViewType = ColorNavView

    public let id = UUID()
    
    public let type: RouteDestinationType = .colorNav
    
    public var view: ViewType?
    
    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, AppContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, AppContentType, TabType> = GroupDestinationInternalState()
    

    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

    func prepareForPresentation() {
    }
}
