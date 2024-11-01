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
    typealias Destination = ColorsListDestination
    
    let interactorType: InteractorType = .colors
    
    var actionType: ColorsRequest.ActionType
    
    var requestMethod: Destinations.InteractorRequestMethod = .sync

    var completionClosure: DatasourceResponseClosure<[ColorViewModel]>?
    
    init(actionType: ColorsRequest.ActionType) {
        self.actionType = actionType
    }
    
    func handleRequest(destination: Destination) {
        
        switch actionType {
            case .retrieve:
                let request = ColorsRequest(action: actionType)
                destination.performRequest(interactor: .colors, request: request, completionClosure: completionClosure)

            case .paginate:
                let request = ColorsRequest(action: actionType, numColorsToRetrieve: 5)
                destination.performRequest(interactor: .colors, request: request, completionClosure: completionClosure)

        }
    }
    
}
