//
//  ColorsListDestination.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ColorDetailSelectionModel: Hashable {
    
    var color: ColorViewModel?
    var targetID: UUID?
    
}

@Observable
final class ColorsListDestination: AppDestinationTypes, ControllerDestinationable {
    
    enum UserInteractions: UserInteractionTypeable {
        case color(model: ColorViewModel?)
        case retrieveInitialColors
        case moreButton
        
        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .retrieveInitialColors:
                    return "retrieveInitialColors"
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
    
    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    

    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
    

    func handleAsyncInteractorResult<Request: InteractorRequestConfiguring>(result: Result<Request.ResultData, Error>, for request: Request) async {
        
        switch result {
            case .success(let content):
                
                switch content as? ColorsRequest.ResultData {
                    case .colors(model: let items):
                        controller?.updateItems(items: items)
                    default: break
                }
                
            case .failure(let error):
                logError(error: error)
        }
        
    }
    
    func prepareForPresentation() {
        
        // load initial color models from datasource
        handleThrowable(closure: {
            try self.performInterfaceAction(interactionType: .retrieveInitialColors)
        })
    }

}
