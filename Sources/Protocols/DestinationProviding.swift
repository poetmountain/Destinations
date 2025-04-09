//
//  DestinationProviding.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This is an abstract protocol which defines Provider classes which build and provide new Destination objects, including their interface elements. Each Provider should be responsible for building a unique Destination and its associated interface.
///
/// > Note: Adopt SDK-specific protocols like ``ViewDestinationProviding`` or ``ControllerDestinationProviding`` when creating your own provider classes.
@MainActor public protocol DestinationProviding {
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// The Destination class to be provided.
    associatedtype Destination: Destinationable
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// A dictionary of presentation configuration models, with their keys being the user interaction type.
    var presentationsData: [Destination.UserInteractionType: DestinationPresentation<DestinationType, ContentType, TabType>] { get set }
    
    /// A dictionary of interactor action configuration models, with their keys being the user interaction type associated with each interactor action.
    var interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>] { get set }
    
    /// Generates Destination presentations associated with this provider.
    func buildPresentations() -> AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>?
    
    /// Generates system navigation presentations supported by Destinations.
    func buildSystemPresentations() -> AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?
    
    /// Assigns interactor assistants to the supplied Destination.
    /// - Parameter destination: The Destination to have interactor assistants applied to.
    func assignInteractorAssistants(for destination: Destination)
    
}

public extension DestinationProviding {
    func buildPresentations() -> AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>? {
        
        let configurations = AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>()
        
        for (interactionType, configuration) in presentationsData {
            let presentation = configuration.copy()
            if let interactionType = interactionType as? Destination.UserInteractionType {
                configurations.addConfiguration(configuration: presentation, for: interactionType)
            }
        }
        
        return configurations
    }
    
    func buildSystemPresentations() -> AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>? {
        
        let configurations = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>()
        
        let backSelection = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .navigationStack(type: .goBack), actionType: .systemNavigation, assistantType: .basic)
        let sheetDismiss = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .sheet(type: .dismiss), actionType: .systemNavigation, assistantType: .basic)
        let systemNavigations: [SystemNavigationType: DestinationPresentation<DestinationType, ContentType, TabType>] = [.navigateBackInStack: backSelection, .dismissSheet: sheetDismiss]
        
        for (interactionType, configuration) in systemNavigations {
            let presentation = configuration.copy()
            
            configurations.addConfiguration(configuration: presentation, for: interactionType)
            
        }
        
        return configurations
    }

    func assignInteractorAssistants(for destination: Destination) {
        for (interactionType, configuration) in interactorsData {
            configuration.assignInteractorAssistant(destination: destination, interactionType: interactionType)
        }
    }
}
