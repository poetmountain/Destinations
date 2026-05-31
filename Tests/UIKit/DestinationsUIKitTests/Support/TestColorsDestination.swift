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
    @AutoCaseIterable
    enum Events: EventTypeable {
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
        
        static func == (lhs: Events, rhs: Events) -> Bool {
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
    
    typealias EventType = Events
    typealias DestinationConfigurations = AppDestinationConfigurations<EventType, DestinationType, AppContentType, TabType>
    typealias ControllerType = TestColorsViewController
    
    public let id = UUID()
    
    public let type: RouteDestinationType = .colorsList
    
    public var controller: ControllerType?
    
    public var internalState: DestinationInternalState<EventType, DestinationType, AppContentType, TabType, InteractorType> = DestinationInternalState()

    var stateModel: (any StateModeling<TestColorsDestination>)?

    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

}


struct TestColorsInteractorAssistant: InteractorAssisting, DestinationTypes {
    
    typealias InteractorType = TestColorsDestination.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors
    let requestMethod: InteractorRequestMethod = .sync

    func handleRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) where Destination.InteractorType == InteractorType {
        
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
