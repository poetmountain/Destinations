//
//  ColorDetailProvider.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 10/24/24.
//

import Foundation
import Destinations

final class ColorDetailProvider: ControllerDestinationProviding, DestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias UserInteractionType = ColorDetailDestination.UserInteractions
    public typealias InteractorType = ColorDetailDestination.InteractorType
    
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
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> (any ControllerDestinationable)? {
        
        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }

        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
        
        let destination = ColorDetailDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let datasource = ColorsDatasource()
        destination.setupInteractor(interactor: datasource, for: .test)

        let controller = ColorDetailViewController(destination: destination, colorModel: colorModel)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
