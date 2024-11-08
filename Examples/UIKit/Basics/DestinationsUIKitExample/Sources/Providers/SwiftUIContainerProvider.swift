//
//  SwiftUIContainerProvider.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 10/24/24.
//

import UIKit
import SwiftUI
import Destinations


final class SwiftUIContainerProvider<SwiftUIView: ViewDestinationInterfacing & SwiftUIHostedInterfacing>: ControllerDestinationProviding, DestinationTypes {
    
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias UserInteractionType = SwiftUIView.UserInteractionType
    public typealias InteractorType = SwiftUIView.InteractorType
    
    public typealias SwiftUIViewSetupClosure = (_ destination: SwiftUIContainerDestination<SwiftUIView, PresentationConfiguration>, _ content: ContentType?) -> SwiftUIView

    public var presentationsData: [UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [UserInteractionType : any InteractorConfiguring<InteractorType>] = [:]
        
    var viewSetup: SwiftUIViewSetupClosure
    
    init(viewSetup: @escaping SwiftUIViewSetupClosure, presentationsData: [UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>]? = nil) {
        self.viewSetup = viewSetup
        
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(for configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> (any ControllerDestinationable)? {
        
        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
        
        let destination = SwiftUIContainerDestination<SwiftUIView, PresentationConfiguration>(destinationType: .swiftUI, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)
         
        let view = self.viewSetup(destination, configuration.contentType)
        
        let adapter = SwiftUIAdapter<SwiftUIView>(content: { view })
         adapter.hostingController.sizingOptions = .intrinsicContentSize

        let containerController = SwiftUIContainerController<SwiftUIView>(adapter: adapter)
       destination.assignAssociatedController(controller: containerController)

        return destination
        
    }
    
}

