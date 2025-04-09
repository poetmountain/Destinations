//
//  ColorsListProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorsListProvider: ViewDestinationProviding, AppDestinationTypes {
    
    public typealias Destination = ColorsListDestination
    typealias UserInteractionType = Destination.UserInteractionType

    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destination = ColorsListDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let listView = ColorsListView(destination: destination)
        destination.assignAssociatedView(view: listView)

        let colorsResponse: InteractorResponseClosure<ColorsRequest> = { [weak destination] (result: Result<ColorsRequest.ResultData, Error>, request: ColorsRequest) in
            switch result {
                case .success(let data):
                    
                    switch request.action {
                        case .retrieve:
                            DestinationsSupport.logger.log("retrieve success for destination \(String(describing: destination?.type))")
                        case .paginate:
                            DestinationsSupport.logger.log("paginate success! \(data)")
                    }
                    
                case .failure(let error):
                    DestinationsSupport.logger.log("error \(error.localizedDescription)", category: .error)
            }
        }
        
        let datasource = ColorsDatasource(with: ColorsPresenter())
        datasource.assignResponseForAction(response: colorsResponse, for: .paginate)
        datasource.assignResponseForAction(response: colorsResponse, for: .retrieve)
        destination.assignInteractor(interactor: datasource, for: .colors)
        

        
         return destination
        
    }
    

}
