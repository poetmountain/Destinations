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
    
    public typealias EventType = SwiftUIView.EventType
    public typealias InteractorType = SwiftUIView.InteractorType
    typealias ContentType = SwiftUIView.ContentType
    typealias TabType = SwiftUIView.TabType
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    
    public typealias Destination = SwiftUIContainerDestination<SwiftUIView, EventType, DestinationType, ContentType, TabType, InteractorType>

    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<SwiftUIView, EventType, DestinationType, ContentType, TabType, InteractorType>, _ content: ContentType?) -> SwiftUIView

    public var presentationsData: [EventType: DestinationPresentation<DestinationType, ContentType, TabType>] = [:]
    public var interactorsData: [EventType : any InteractorConfiguring<InteractorType>] = [:]
        
    var viewSetup: SwiftUIViewSetupClosure
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destination = SwiftUIContainerDestination<SwiftUIView, EventType, DestinationType, ContentType, TabType, InteractorType>(destinationType: DestinationType.swiftUI, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
         
        let view = self.viewSetup(destination, configuration.contentType)
        
        let adapter = SwiftUIAdapter<SwiftUIView>(content: { view })
         adapter.hostingController.sizingOptions = .intrinsicContentSize

        let containerController = SwiftUIContainerController<SwiftUIView>(adapter: adapter)
       destination.assignAssociatedController(controller: containerController)

        return destination
        
    }
    
}

