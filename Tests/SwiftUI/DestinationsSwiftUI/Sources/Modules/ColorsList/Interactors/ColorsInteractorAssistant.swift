//
//  ColorsInteractorAssistant.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ColorsInteractorAssistant: AsyncInteractorAssisting, DestinationTypes {
    
    typealias InteractorType = ColorsListDestination.InteractorType
    typealias Request = ColorsRequest
    
    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {
        switch actionType {
            case .retrieve:
                let request = ColorsRequest(action: actionType)
                let result = await destination.performRequest(interactor: interactorType, request: request)
                await destination.handleAsyncInteractorResult(result: result, for: request)

            case .paginate:
                let request = ColorsRequest(action: actionType, numColorsToRetrieve: 5)
                let result = await destination.performRequest(interactor: interactorType, request: request)
                await destination.handleAsyncInteractorResult(result: result, for: request)
        }
    }
    
}
