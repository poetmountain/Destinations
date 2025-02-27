//
//  ViewDestinationProviding.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents objects which construct and provide ``ViewDestinationable`` objects, including their associated interface elements. Provider objects which conform to this protocol should build discrete Destinations based on their specific destination type.
@MainActor public protocol ViewDestinationProviding<PresentationConfiguration>: DestinationProviding {
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    
    /// Builds and returns a new ``ViewDestinationable`` object based on the supplied configuration object.
    /// - Parameters:
    ///   - presentations: The Destination presentations associated with this provider.
    ///   - systemPresentations: The system navigation presentations supported by Destinations.
    ///   - configuration: A ``DestinationPresentationConfiguring`` object which provides configuration data to construct the Destination.
    ///   - appFlow: A reference to the ``Flowable`` object which should call this method. This is necessary in cases where a Destination type needs to create children Destinations as part of its construction.
    /// - Returns: The newly created ``ViewDestinationable`` object.
    func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination?
}

public extension ViewDestinationProviding {
    
    internal func buildAndConfigureDestination(for configuration: PresentationConfiguration, appFlow: some ViewFlowable<PresentationConfiguration>) -> Destination? {
        
        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
        
        let destination = buildDestination(destinationPresentations: destinationPresentations, navigationPresentations: navigationPresentations, configuration: configuration, appFlow: appFlow)
        
        if let destination {
            assignInteractorAssistants(for: destination)
        }
                
        return destination
    }
}
