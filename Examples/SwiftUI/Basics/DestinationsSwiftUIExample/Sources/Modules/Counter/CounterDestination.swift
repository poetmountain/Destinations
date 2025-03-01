//
//  CounterDestination.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class CounterDestination: ViewDestinationable, DestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable, Equatable {
        
        case start
        case stop
        
        var rawValue: String {
            switch self {
                case .start:
                    return "start"
                case .stop:
                    return "stop"
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
        case counter
    }

    typealias ViewType = CounterView
    typealias UserInteractionType = UserInteractions

    public let id = UUID()
    
    public let type: RouteDestinationType = .counter
    
    public var view: ViewType?
    
    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()

    var counter: Int = 0

    private(set) var listID: UUID = UUID()

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    func handleInteractorResult<Request>(result: Result<Request.ResultData, any Error>, for request: Request) where Request : InteractorRequestConfiguring {
        
        switch result {
            case .success(let response):
                switch response as? CounterRequest.ResultData {
                    case .count(value: let increment):
                        self.counter += increment
                        
                    default: break
                }
            case .failure(let error):
                print("error \(error)")
        }
    }

    func prepareForPresentation() {
        
    }
}
