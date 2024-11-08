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
    
    /// An enum which defines user interaction types for this Destination's interface.
    associatedtype UserInteractionType: UserInteractionTypeable
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    associatedtype InteractorType: InteractorTypeable
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring<DestinationType, TabType, ContentType>
    
    /// A dictionary of presentation configuration models, with their keys being the user interaction type.
    var presentationsData: [UserInteractionType: PresentationConfiguration] { get set }
    
    /// A dictionary of interactor action configuration models, with their keys being the user interaction type associated with each interactor action.
    var interactorsData: [UserInteractionType: any InteractorConfiguring<InteractorType>] { get set }
    
    /// Generates Destination presentations associated with this provider.
    func buildPresentations() -> AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>?
    
    /// Generates system navigation presentations supported by Destinations.
    func buildSystemPresentations() -> AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?
}

public extension DestinationProviding {
    func buildPresentations() -> AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>? {
        
        let configurations = AppDestinationConfigurations<UserInteractionType, PresentationConfiguration>()
        
        for (interactionType, configuration) in presentationsData {
            let presentation = configuration.copy()
            
            if let interactionType = interactionType as? UserInteractionType {
                configurations.addConfiguration(configuration: presentation, for: interactionType)
            }
        }
        
        return configurations
    }
    
    func buildSystemPresentations() -> AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>? {
        
        let configurations = AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>()
        
        let backSelection = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .navigationController(type: .goBack), actionType: .systemNavigation, assistantType: .basic)
        let sheetDismiss = DestinationPresentation<DestinationType, ContentType, TabType>(presentationType: .sheet(type: .dismiss), actionType: .systemNavigation, assistantType: .basic)
        let systemNavigations: [SystemNavigationType: DestinationPresentation<DestinationType, ContentType, TabType>] = [.navigateBackInStack: backSelection, .dismissSheet: sheetDismiss]
        
        for (interactionType, configuration) in systemNavigations {
            let presentation = configuration.copy()
            
            configurations.addConfiguration(configuration: presentation, for: interactionType)
            
        }
        
        return configurations
    }
}