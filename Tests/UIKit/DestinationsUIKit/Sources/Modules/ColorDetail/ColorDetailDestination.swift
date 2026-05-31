//
//  ColorDetailDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class ColorDetailDestination: ControllerDestinationable, DestinationTypes {

    @AutoCaseIterable
    enum Events: EventTypeable {
        case colorDetailButton(model: ColorViewModel?)
        case moveToNearest

        var rawValue: String {
            switch self {
                case .colorDetailButton(_):
                    return "colorDetailButton"
                case .moveToNearest:
                    return "moveToNearest"
            }
        }

        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    typealias EventType = Events
    typealias DestinationConfigurations = AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>
    typealias ControllerType = ColorDetailViewController

    public let id = UUID()

    public let type: RouteDestinationType = .colorDetail

    public var controller: ControllerType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()

    var stateModel: (any StateModeling<ColorDetailDestination>)?

    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        internalState.parentDestinationID = parentDestination
        internalState.destinationConfigurations = destinationConfigurations
        internalState.systemNavigationConfigurations = navigationConfigurations
    }
}
