//
//  TestColorsDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations
@testable import DestinationsUIKit

@Observable
final class TestColorsDestination: DestinationTypes, ControllerDestinationable {
    
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
    typealias ControllerType = TestColorsViewController
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
    

    func handleInteractorResult<Request: InteractorRequestConfiguring>(result: Result<ContentType, Error>, for request: Request) async {
        
        switch result {
            case .success(let content):
                
                switch content {
                    case .colors(models: let items):
                        await controller?.updateItems(items: items)
                    default: break
                }
                
            case .failure(let error):
                logError(error: error)
        }
        
    }
    
    func prepareForPresentation() {
        handleThrowable(closure: {
            try self.performInterfaceAction(interactionType: .retrieveInitialColors)
        })
    }

}


struct TestColorsInteractorAssistant: InteractorAssisting, DestinationTypes {
    
    typealias InteractorType = TestColorsDestination.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors
    let actionType: ColorsRequest.ActionType
    let requestMethod: InteractorRequestMethod = .sync

    init(actionType: ColorsRequest.ActionType) {
        self.actionType = actionType
    }
    
    func handleRequest<Destination: Destinationable>(destination: Destination, content: ContentType?) where Destination.InteractorType == InteractorType {
        
        switch actionType {
            case .retrieve:
                let request = ColorsRequest(action: actionType)
                destination.performRequest(interactor: interactorType, request: request)
                
            case .paginate:
                let request = ColorsRequest(action: actionType, numColorsToRetrieve: 5)
                destination.performRequest(interactor: interactorType, request: request)

        }
    }
    
}
