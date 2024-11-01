//
//  ColorsListDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ColorDetailSelectionModel: Hashable {
    
    var color: ColorViewModel?
    var targetID: UUID?
    
}

@Observable
final class ColorsListDestination: DestinationTypes, ControllerDestinationable {
    
    
    enum UserInteractions: UserInteractionTypeable {
        case color(model: ColorViewModel?)
        case moreButton
        
        var rawValue: String {
            switch self {
                case .color(_):
                    return "color"
                case .moreButton:
                    return "moreButton"
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
        
        var rawValue: String {
            switch self {
                case .colors:
                    return "colors"
            }
        }
        
        static func == (lhs: InteractorType, rhs: InteractorType) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationPresentation<DestinationType, AppContentType, TabType>>
    typealias ControllerType = ColorsViewController
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    
    public let id = UUID()
    
    public let type: RouteDestinationType = .colorsList
    
    public var controller: ControllerType?
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    var systemNavigationConfigurations: NavigationConfigurations?

    public var isSystemNavigating: Bool = false
    
    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractions : any InteractorAssisting<ColorsListDestination>] = [:]

    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }
    
    func configureInteractor(_ interactor: any Interactable, type: InteractorType) {
        
        switch type {
            case .colors:
                
                if interactor is any AsyncDatasourceable<ColorsRequest.ResultData> {
                    Task {
                        let request = ColorsRequest(action: .retrieve)
                        
                        let result = await performRequest(interactor: .colors, request: request)
                        await self.controller?.handleColorsResult(result: result)
                    }
                }
        }
        
    }

}
