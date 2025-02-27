//
//  ColorDetailDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

final class ColorDetailDestination: ControllerDestinationable, DestinationTypes {
    
    enum UserInteractions: UserInteractionTypeable {
        case color
        case colorDetailButton(model: ColorViewModel?)
        case customDetailButton(model: ColorViewModel?)

        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .colorDetailButton(_):
                    return "colorDetailButton"
                case .customDetailButton(_):
                    return "customDetailButton"
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
    typealias ControllerType = ColorDetailViewController
    
    public let id = UUID()
    
    public let type: RouteDestinationType = .colorDetail
    
    public var controller: ControllerType?
    
    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    
    public var parentDestinationID: UUID?
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    func prepareForPresentation() {
    }
}
