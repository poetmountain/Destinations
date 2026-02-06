//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorDetailProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias Destination = ColorDetailDestination

    public var presentationsData: [Destination.UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init() {
        let options = ViewSheetPresentationOptions(presentationMode: .sheet)
        let sheetPresent = DestinationPresentation<DestinationType, ContentType, TabType>(destinationType: .dynamic, presentationType: .sheet(type: .present, options: SheetPresentationOptions(swiftUI: options)), assistantType: .custom(ColorDetailActionAssistant()))
        
        let moveNearest = PresentationConfiguration(presentationType: .moveToNearest(destination: .colorDetail), assistantType: .basic)
        
        
        presentationsData = [.colorDetailButton: moveNearest]
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
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
