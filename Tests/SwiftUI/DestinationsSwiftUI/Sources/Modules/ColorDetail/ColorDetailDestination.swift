//
//  ColorDetailDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct CollectionDatasourceOptions {
    let numItemsToDisplay: Int?
}

@Observable
final class ColorDetailDestination: ViewDestinationable, DestinationTypes {
    enum UserInteractions: UserInteractionTypeable, Equatable {
        case color(model: ColorDetailSelectionModel)
        
        var rawValue: String {
            switch self {
                case .color(_):
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
    
    enum InteractorType: InteractorTypeable {
        case colors
    }
    
    typealias ViewType = ColorDetailView
    typealias UserInteractionType = UserInteractions


    public let id = UUID()
    
    public let type: RouteDestinationType = .colorDetail
    
    public var view: ViewType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()

    var items: [ColorViewModel] = []

    private(set) var listID: UUID = UUID()

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

    func prepareForPresentation() {
    }
}
