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
final class ColorDetailDestination: ViewDestinationable, AppDestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable, Equatable {
        case color(model: ColorDetailSelectionModel)
        case colorDetailButton
        
        var rawValue: String {
            switch self {
                case .color(_):
                    return "color"
                case .colorDetailButton:
                    return "colorDetailButton"
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

    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractions : any InteractorAssisting<ColorDetailDestination>] = [:]

    var items: [ColorViewModel] = []

    private(set) var listID: UUID = UUID()

    public var isSystemNavigating: Bool = false

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }

}
