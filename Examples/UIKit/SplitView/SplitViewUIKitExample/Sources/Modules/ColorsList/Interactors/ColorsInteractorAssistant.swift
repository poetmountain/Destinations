//
//  ColorsInteractorAssistant.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ColorsInteractorAssistant: AsyncInteractorAssisting, AppDestinationTypes {

    typealias InteractorType = ColorsListDestination.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors
    
    let actionType: ColorsRequest.ActionType
    
    let requestMethod: InteractorRequestMethod = .async
        
    init(actionType: ColorsRequest.ActionType) {
        self.actionType = actionType
    }
    
    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, content: Request.ResultData?) async where Destination.InteractorType == InteractorType {
        
        switch actionType {
            case .retrieve:
                let request = ColorsRequest(action: actionType)
                let result = await destination.performRequest(interactor: interactorType, request: request)
                await destination.handleInteractorResult(result: result, for: request)
                
            case .paginate:
                let request = ColorsRequest(action: actionType, numColorsToRetrieve: 5)
                let result = await destination.performRequest(interactor: interactorType, request: request)
                await destination.handleInteractorResult(result: result, for: request)

        }
                
    }
    
}
