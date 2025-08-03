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
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    public typealias Destination = ColorDetailDestination
    
    public var presentationsData: [Destination.UserInteractionType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    let transitionAnimator = AnimationTransitionCoordinator()

    init() {
        let options = SheetPresentationOptions(uiKit: ControllerSheetPresentationOptions(presentationStyle: .formSheet, configurationClosure: { sheet in
            
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }))
        let sheetPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .sheet(type: .present, options: options), assistantType: .custom(ColorDetailActionAssistant()))
        let customOptions = SheetPresentationOptions(uiKit: ControllerSheetPresentationOptions(presentationStyle: .custom, transitionDelegate: transitionAnimator))
        let customSheetPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .sheet(type: .present, options: customOptions), assistantType: .custom(ColorDetailActionAssistant()))
        
        
        let customPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .custom(presentation: CustomPresentation<DestinationType, AppContentType, TabType>(uiKit: { (destinationToPresent, rootController, currentDestination, parentOfCurrentDestination, completionClosure) in
            guard destinationToPresent != nil else {
                completionClosure?(false)
                return
            }
                       
            completionClosure?(true)
            
        })), assistantType: .basic)
        
        presentationsData = [.colorDetailButton(model: nil): sheetPresent, .customDetailButton(model: nil): customSheetPresent]
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, AppContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, AppContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, AppContentType, TabType>) -> Destination? {
        
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
