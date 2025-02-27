//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class ColorDetailProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias Destination = ColorDetailDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init(presentationsData: [Destination.UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {
        
        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }
        
        let destination = ColorDetailDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)


        var view = ColorDetailView(destination: destination, model: colorModel)
        
        let sheetView = ContainerView {
            AnyView(
                ColorSheetView(colorModel: colorModel, dismissButtonClosure: { [weak sheetPresentation = view.sheetPresentation] in
                    sheetPresentation?.dismissSheet()
                })
            )
        }
        
        view.updateSheetView(sheetView: sheetView)
        destination.assignAssociatedView(view: view)

        return destination
        
    }
    
}
