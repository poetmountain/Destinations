//
//  ColorsListProvider.swift
///
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class ColorsListProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias ViewDestinationableType = ColorsListDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = ColorsListDestination.UserInteractions
    public typealias InteractorType = ColorsListDestination.InteractorType
    
    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
    
    init(presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> (any ViewDestinationable)? {
        
        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
        
        let destination = ColorsListDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let listView = ColorsListView(destination: destination)
        destination.assignAssociatedView(view: listView)

        let datasource = ColorsDatasource(with: ColorsPresenter())
        destination.setupInteractor(interactor: datasource, for: .colors)
        
        let completionClosure: DatasourceResponseClosure<[ColorsRequest.ResultData]> = { (result: Result<[ColorsRequest.ResultData], Error>) in
            
            switch result {
                case .success(let data):
                    DestinationsSupport.logger.log("request more success! \(data)")
                case .failure(let error):
                    DestinationsSupport.logger.log("error \(error.localizedDescription)", category: .error)
            }
        }
        
        for (interactionType, setupModel) in interactorsData {
            switch setupModel.interactorType {
                case .colors:
                    if let setupModel = setupModel as? InteractorConfiguration<InteractorType, ColorsDatasource> {
                        var assistant = ColorsInteractorAssistant(actionType: setupModel.actionType)
                        assistant.completionClosure = completionClosure
                        destination.assignInteractorAssistant(assistant: assistant, for: interactionType)
                    }
            }
        }
        
         return destination
        
    }
    

}
