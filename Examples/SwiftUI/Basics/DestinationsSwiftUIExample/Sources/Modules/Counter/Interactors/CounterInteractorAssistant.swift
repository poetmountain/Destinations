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
    
    typealias InteractorType = CounterView.InteractorType
    typealias Request = CounterRequest
    
    let interactorType: InteractorType = .counter
    let requestMethod: InteractorRequestMethod = .async

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: AppContentType?) async where Destination.InteractorType == InteractorType {
        
        let request = CounterRequest(action: actionType)
        
        switch actionType {
            case .startCount:
                if let interactor = destination.interactor(for: interactorType) as? CounterInteractor {

                    guard await interactor.isCounting == false else { return }
                    _ = await destination.performRequest(interactor: interactorType, request: request)

                    // handle the AsyncStream which provides counter updates
                    guard let stream = await interactor.stream else { return }
                    
                    for await count in stream {
                        let countResult: Result<Request.ResultData, Error> = .success(.count(value: count, isFinished: false))
                        await destination.handleAsyncInteractorResult(result: countResult, for: request)
                    }
                    
                }
            case .stopCount:
                _ = await destination.performRequest(interactor: interactorType, request: request)

                if let interactor = destination.interactor(for: interactorType) as? CounterInteractor {
                    await destination.handleAsyncInteractorResult(result: .success(.count(value: await interactor.counter, isFinished: true)), for: request)
                }
        }
    }
    
}
