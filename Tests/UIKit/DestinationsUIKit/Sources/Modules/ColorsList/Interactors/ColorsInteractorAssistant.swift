//
//  ColorsInteractorAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ColorsInteractorAssistant: InteractorAssisting, DestinationTypes {

    typealias InteractorType = ColorsListDestination.InteractorType
    typealias Request = ColorsRequest
    typealias Destination = ColorsListDestination
    
    let interactorType: InteractorType = .colors
    
    var actionType: ColorsRequest.ActionType
    
    var requestMethod: InteractorRequestMethod = .async
    
    var completionClosure: DatasourceResponseClosure<[ColorViewModel]>?
    
    init(actionType: ColorsRequest.ActionType) {
        self.actionType = actionType
    }
    
    func handleAsyncRequest(destination: Destination) async {
        
        switch actionType {
            case .retrieve:
                let request = ColorsRequest(action: actionType)
                let result = await destination.performRequest(interactor: .colors, request: request)
                await destination.controller?.handleColorsResult(result: result)

            case .paginate:
                let request = ColorsRequest(action: actionType, numColorsToRetrieve: 5)
                let result = await destination.performRequest(interactor: .colors, request: request)
                await destination.controller?.handleColorsResult(result: result)
        }
                
    }
    
    
}
