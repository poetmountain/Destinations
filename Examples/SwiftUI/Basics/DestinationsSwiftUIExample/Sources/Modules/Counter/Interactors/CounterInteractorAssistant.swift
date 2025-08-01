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

struct CounterInteractorAssistant: AsyncInteractorAssisting, DestinationTypes {
    
    typealias InteractorType = CounterDestination.InteractorType
    typealias Request = CounterRequest
    
    let interactorType: InteractorType = .counter
    let actionType: CounterRequest.ActionType
    let requestMethod: InteractorRequestMethod = .async

    func handleAsyncRequest<Destination>(destination: Destination, content: AppContentType?) async where Destination : Destinationable, CounterDestination.InteractorType == Destination.InteractorType {
        
        let request = CounterRequest(action: actionType)
        _ = await destination.performRequest(interactor: interactorType, request: request)
        
        switch actionType {
            case .startCount:
                if let interactor = destination.interactor(for: interactorType) as? CounterInteractor {
                    print("starting count")

                    // handle the AsyncStream which provides counter updates
                    for await count in interactor.stream {
                        let countResult: Result<Request.ResultData, Error> = .success(.count(value: count))
                        destination.handleInteractorResult(result: countResult, for: request)
                    }
                    
                }
            case .stopCount:
                break
        }
    }
    
}
