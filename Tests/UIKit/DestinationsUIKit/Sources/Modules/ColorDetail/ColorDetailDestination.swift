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
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    var systemNavigationConfigurations: NavigationConfigurations?

    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<ColorDetailDestination>] = [:]

    var childDestinations: [any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>] = []
    var currentChildDestination: (any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>)?

    public var isSystemNavigating: Bool = false
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }
    

    public func performInterfaceAction(interactionType: UserInteractionType) {

        if var closure = interfaceActions[interactionType] {

            closure.data.parentID = self.id
            
            switch interactionType {
                case .colorDetailButton(model: let model), .customDetailButton(model: let model):
                    if let model, closure.data.contentType == nil {
                        closure.data.contentType = .color(model: model)
                    }
                case .color:
                    break
            }
            
            closure()
            
        }
    }

}
