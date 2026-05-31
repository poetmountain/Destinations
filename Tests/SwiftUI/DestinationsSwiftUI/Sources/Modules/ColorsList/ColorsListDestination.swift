//
//  ColorsListDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class ColorsListDestination: DestinationTypes, NavigatingViewDestinationable {
    
    typealias ViewType = ColorsListView
    typealias EventType = Events

    @AutoCaseIterable
    enum Events: EventTypeable {
        case color(model: ColorViewModel?)
        case retrieveInitialColors
        
        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .retrieveInitialColors:
                    return "retrieveInitialColors"
            }
        }
        
        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    enum InteractorType: InteractorTypeable {
        case colors
    }
        
    public let id = UUID()
    
    public let type: RouteDestinationType = .colorsList
    
    public var view: ViewType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

    var stateModel: (any StateModeling<ColorsListDestination>)?

    private(set) var listID: UUID = UUID()

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
}
