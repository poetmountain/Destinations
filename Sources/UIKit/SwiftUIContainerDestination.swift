//
//  SwiftUIContainerDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A Destination representing a ``SwiftUIContainerController`` instance which presents a SwiftUI `View` within UIKit.
public final class SwiftUIContainerDestination<ViewType: SwiftUIHostedInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: SwiftUIContainerDestinationable {
    
    /// A type of ``AppDestinationConfigurations`` which handles Destination presentation configurations.
    public typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>
    public typealias ControllerType = SwiftUIContainerController<ViewType>
    
    public let id = UUID()
    
    public let type: DestinationType
    
    public var controller: SwiftUIContainerController<ViewType>?
    
    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()

    
    /// This `ViewFlow` object manages the SwiftUI `View` presented by this Destination.
    public var viewFlow: ViewFlow<DestinationType, TabType, ContentType>?


    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestination: The identifier of the parent Destination.
    public init(destinationType: DestinationType, flow: ViewFlow<DestinationType, TabType, ContentType>? = nil, destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.type = destinationType
        if let flow {
            self.viewFlow = flow
        }
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    public func buildInterfaceActions(presentationClosure: @escaping (DestinationPresentation<DestinationType, ContentType, TabType>) -> Void) {
        guard let destinationConfigurations = internalState.destinationConfigurations else { return }

        var containers: [InterfaceAction<UserInteractionType, DestinationType, ContentType>] = []
        for (type, configuration) in destinationConfigurations.configurations {
            let container = buildInterfaceAction(presentationClosure: presentationClosure, configuration: configuration, interactionType: type)
            containers.append(container)
        }
        
        updateInterfaceActions(actions: containers)
        
    }
    
    public func presentDestination(presentation: DestinationPresentation<DestinationType, ContentType, TabType>) {
        let copiedPresentation = presentation.copy()
        if case .splitView(column: let column) = presentation.presentationType {
            copiedPresentation.presentationType = .navigationStack(type: .present)
        }
        viewFlow?.presentDestination(configuration: copiedPresentation)
    }

    public func cleanupResources() {
        controller?.cleanupResources()
    }
    
    public func prepareForPresentation() {
    }
}

