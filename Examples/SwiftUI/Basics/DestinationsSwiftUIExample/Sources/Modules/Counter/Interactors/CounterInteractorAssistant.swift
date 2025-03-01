//
//  CounterInteractorAssistant.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct CounterInteractorAssistant: InteractorAssisting, DestinationTypes {
    
    typealias InteractorType = CounterDestination.InteractorType
    typealias Request = CounterRequest
    
    let interactorType: InteractorType = .counter
    let actionType: CounterRequest.ActionType
    
    func handleRequest<Destination: Destinationable>(destination: Destination, content: Request.RequestContentType?) where Destination.InteractorType == InteractorType {
        
        let request = CounterRequest(action: actionType)
        destination.performRequest(interactor: interactorType, request: request)
        
        switch actionType {
            case .startCount:

                if let interactor = destination.interactor(for: interactorType) as? CounterInteractor {
                    // handle the AsyncStream which provides counter updates
                    Task {
                        for await count in interactor.stream {
                            let countResult: Result<Request.ResultData, Error> = .success(.count(value: count))
                            destination.handleInteractorResult(result: countResult, for: request)
                        }
                    }
                }
            case .stopCount:
                break
        }
                
    }
    
}
