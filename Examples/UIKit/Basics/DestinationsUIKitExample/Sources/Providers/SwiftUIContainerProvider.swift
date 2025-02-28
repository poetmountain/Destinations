//
//  SwiftUIContainerProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import SwiftUI
import Destinations


struct SwiftUIContainerProvider<SwiftUIView: ViewDestinationInterfacing & SwiftUIHostedInterfacing>: ControllerDestinationProviding, DestinationTypes {
    
    public typealias Destination = SwiftUIContainerDestination<SwiftUIView, PresentationConfiguration>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias UserInteractionType = SwiftUIView.UserInteractionType
    public typealias InteractorType = SwiftUIView.InteractorType
    
    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<SwiftUIView, PresentationConfiguration>, _ content: ContentType?) -> SwiftUIView

    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
        
    var viewSetup: SwiftUIViewSetupClosure
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
        
        let destination = SwiftUIContainerDestination<SwiftUIView, PresentationConfiguration>(destinationType: .swiftUI, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
         
        let view = self.viewSetup(destination, configuration.contentType)
        
        let adapter = SwiftUIAdapter<SwiftUIView>(content: { view })
         adapter.hostingController.sizingOptions = .intrinsicContentSize

        let containerController = SwiftUIContainerController<SwiftUIView>(adapter: adapter)
       destination.assignAssociatedController(controller: containerController)

        return destination
        
    }
    
}

