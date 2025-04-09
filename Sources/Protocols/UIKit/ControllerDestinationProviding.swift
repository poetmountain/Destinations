//
//  ControllerDestinationProviding.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents objects which construct and provide ``ControllerDestinationable`` objects, including their associated interface elements. Provider objects which conform to this protocol should build discrete Destinations based on their specific destination type.
@MainActor public protocol ControllerDestinationProviding<DestinationType, ContentType, TabType>: DestinationProviding {
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>

    /// Builds and returns a new ``ControllerDestinationable`` object based on the supplied configuration object.
    /// - Parameters:
    ///   - presentations: The Destination presentations associated with this provider.
    ///   - systemPresentations: The system navigation presentations supported by Destinations.
    ///   - configuration: A ``DestinationPresentation`` object which provides configuration data to construct the Destination.
    ///   - appFlow: A reference to the ``Flowable`` object which should call this method. This is necessary in cases where a Destination type needs to create children Destinations as part of its construction.
    /// - Returns: The newly created ``ControllerDestinationable`` object.
    func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination?
}

public extension ControllerDestinationProviding {
    
    internal func buildAndConfigureDestination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ControllerFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destinationPresentations = buildPresentations()
        let navigationPresentations = buildSystemPresentations()
        
        let destination = buildDestination(destinationPresentations: destinationPresentations, navigationPresentations: navigationPresentations, configuration: configuration, appFlow: appFlow)
        
        if let destination {
            assignInteractorAssistants(for: destination)
        }
                
        return destination
    }
}
