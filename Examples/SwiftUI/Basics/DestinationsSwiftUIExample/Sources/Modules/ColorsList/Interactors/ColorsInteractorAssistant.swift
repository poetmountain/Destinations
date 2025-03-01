//
//  ColorsInteractorAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ColorsInteractorAssistant: InteractorAssisting, DestinationTypes {
    
    typealias InteractorType = ColorsListDestination.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors
    let actionType: ColorsRequest.ActionType
    let requestMethod: InteractorRequestMethod = .sync
    
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
