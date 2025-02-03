//
//  ColorDetailDestination.swift
//  SplitViewUIKitExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorDetailSwiftUIDestination: ViewDestinationable, DestinationTypes {

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
    
    typealias ViewType = ColorDetailView

    public let id = UUID()
    
    public let type: RouteDestinationType = .colorDetailSwiftUI
    
    public var view: ViewType?
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    var systemNavigationConfigurations: NavigationConfigurations?

    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<ColorDetailSwiftUIDestination>] = [:]

    
    public var isSystemNavigating: Bool = false
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }


}
