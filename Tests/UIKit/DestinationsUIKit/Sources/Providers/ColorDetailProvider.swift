//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct ColorDetailProvider: ControllerDestinationProviding, DestinationTypes {
    
    typealias UserInteractionType = Destination.UserInteractions
    public typealias Destination = ColorDetailDestination
    
    public var presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init(presentationsData: [UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>]? = nil, interactorsData: [UserInteractionType : any InteractorConfiguring<Destination.InteractorType>]? = nil) {
        
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
        
        let goBackAction = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .navigationStack(type: .goBack), assistantType: .basic)
        let moveToNearestAction = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .moveToNearest(destination: .colorDetail), assistantType: .basic)
        
        self.presentationsData[.moveToNearest] = moveToNearestAction
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<UserInteractionType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }

        let destination = ColorDetailDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
        
        let controller = ColorDetailViewController(destination: destination, colorModel: colorModel)
        destination.assignAssociatedController(controller: controller)

        return destination
        
    }
    
}
