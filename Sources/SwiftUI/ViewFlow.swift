//
//  ViewFlow.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A concrete Flow class designed to be used to manage Destinations flows within the SwiftUI framework. In most cases creating a custom Flow object is unnecessary, and this class can be used as-is in your SwiftUI-based app.
public final class ViewFlow<DestinationType: RoutableDestinations, TabType: TabTypeable, ContentType: ContentTypeable>: ViewFlowable {

    /// An enum which defines all routable Destinations in the app.
    public typealias DestinationType = DestinationType
    
    /// An enum which defines types of tabs in a tab bar.
    public typealias TabType = TabType
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    public typealias ContentType = ContentType
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    
    /// A type of object that coordinates the presentation of a Destination within a UI framework.
    public typealias InterfaceCoordinator = DestinationSwiftUICoordinator

    public var activeDestinations: [any Destinationable<PresentationConfiguration>] = []
    
    public var currentDestination: (any Destinationable<PresentationConfiguration>)?
        
    public var destinationProviders: [DestinationType: any ViewDestinationProviding] = [:]
            
    public var uiCoordinator: DestinationSwiftUICoordinator?
            
    public var rootDestination: (any Destinationable<PresentationConfiguration>)?

    public var destinationQueue: [PresentationConfiguration] = []
    
    /// The starting Destination in the Flow.
    public var startingDestination: PresentationConfiguration?
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationProviders: A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    ///   - startingDestination: The starting Destination.
    public init(destinationProviders: [DestinationType: any ViewDestinationProviding], startingDestination: PresentationConfiguration) {
        self.destinationProviders = destinationProviders
        self.startingDestination = startingDestination
        self.uiCoordinator = DestinationSwiftUICoordinator()

        self.uiCoordinator?.removeDestinationClosure = { [weak self]  (_ uuid: UUID) in
            guard let strongSelf = self else { return }
            strongSelf.removeDestination(destinationID: uuid)
        }
        self.uiCoordinator?.delegate = self
    }

    public func start()  {
        if let startingDestination {
            let loggingStartingAction: String = startingDestination.destinationType != nil ? startingDestination.destinationType.debugDescription : "\(startingDestination.presentationType.rawValue)"
            DestinationsSupport.logger.log("🏁 Starting Destinations flow with \(loggingStartingAction).")
            
            if let newDestination = presentDestination(configuration: startingDestination) {
                rootDestination = newDestination
            }
        
        }
    }

    /// Return an existing destination or build a new one
    public func destination(for configuration: PresentationConfiguration) -> (any ViewDestinationable<PresentationConfiguration>)? {
        
        var existingDestination: (any ViewDestinationable<PresentationConfiguration>)?
        let existingID: UUID? = configuration.actionTargetID
        
        if let existingID {
            if configuration.actionType == .presentation, let activeDestination = activeDestinations.first(where: { $0.parentDestinationID() == existingID }) as? any ViewDestinationable<PresentationConfiguration> {
                existingDestination = activeDestination
                
            } else if case .sheet(type: .dismiss, options: _) = configuration.presentationType,  let activeDestination = activeDestinations.first(where: { $0.parentDestinationID() == existingID || $0.id == existingID }) as? any ViewDestinationable<PresentationConfiguration> {
                existingDestination = activeDestination

            } else if configuration.actionType == .systemNavigation, let activeDestination = activeDestinations.first(where: { $0.id == existingID }) as? any ViewDestinationable<PresentationConfiguration> {
                existingDestination = activeDestination
            }

        }
        
        if let destinationToReturn = existingDestination ?? buildDestination(for: configuration) {
            return destinationToReturn
        } else {
            return nil
        }
    }
    
    
    
    @discardableResult public func presentDestination(configuration: PresentationConfiguration) ->  (any ViewDestinationable<PresentationConfiguration>)? {
        DestinationsSupport.logger.log("⤴️ Presenting destination \(String(describing: configuration.destinationType)) via \(configuration.presentationType)")
        
        if case DestinationPresentationType.destinationPath(path: let path) = configuration.presentationType {
            self.presentDestinationPath(path: path, contentToPass: configuration.contentType)
            return nil
        }
        
        
        var mutableConfiguration = configuration
        var parentOfCurrentDestination: (any ViewDestinationable)?
        
        if let parentID = currentDestination?.parentDestinationID(), let parent = self.destination(for: parentID) as? any ViewDestinationable<PresentationConfiguration> {
            parentOfCurrentDestination = parent
        }
        
        let newDestination = self.destination(for: mutableConfiguration)

        var currentViewDestination = currentDestination as? any ViewDestinationable<PresentationConfiguration>
        
        if case .splitView(column: let column) = configuration.presentationType, let current = currentViewDestination {
            guard column.swiftUI != nil else {
                let template = DestinationsSupport.errorMessage(for: .undefinedSplitViewColumnType(message: ""))
                let message = String(format: template, "uiKit")
                DestinationsSupport.logError(error: DestinationsError.undefinedSplitViewColumnType(message: message))
                
                return nil
            }
            
            currentViewDestination = findSplitViewInViewHierarchy(currentDestination: current)
        }
        
        if var newDestination = newDestination {
            
            if let parentID = currentViewDestination?.parentDestinationID() ?? mutableConfiguration.parentDestinationID, let parent = self.destination(for: parentID) as? any ViewDestinationable {
                parentOfCurrentDestination = parent
            }
            
            if let current = currentViewDestination, let tabDestination = findTabBarInViewHierarchy(searchDestination: current) {
                mutableConfiguration.tabBarDestination = tabDestination
            }
            
            if case DestinationPresentationType.navigationController(type: .present) = mutableConfiguration.presentationType {
                if let currentViewDestination, let navigator = findNavigatorInViewHierarchy(searchDestination: currentViewDestination), let navID = navigator.navigatorDestinationID, let navDestination = self.destination(for: navID) as? any NavigatingViewDestinationable<PresentationConfiguration> {
                    parentOfCurrentDestination = navDestination
                }
            }
            
                    
            mutableConfiguration.completionClosure = self.presentationCompletionClosure(for: mutableConfiguration, destination: newDestination)

            updateDestination(destination: newDestination)
            
            uiCoordinator?.presentViewDestination(destination: newDestination, currentDestination: currentViewDestination, parentOfCurrentDestination: parentOfCurrentDestination, configuration: mutableConfiguration)
            
            
            return newDestination
            
        } else {
            
            if let current = currentViewDestination, let tabDestination = findTabBarInViewHierarchy(searchDestination: current) {
                mutableConfiguration.tabBarDestination = tabDestination
            }
            
            mutableConfiguration.completionClosure = self.presentationCompletionClosure(for: mutableConfiguration, destination: newDestination)

            uiCoordinator?.presentViewDestination(destination: nil, currentDestination: currentViewDestination, parentOfCurrentDestination: parentOfCurrentDestination, configuration: mutableConfiguration)
            
            
        }
        
        return nil
    
    }
    
    
    public func presentationCompletionClosure(for configuration: PresentationConfiguration, destination: (any Destinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)? = nil) -> PresentationCompletionClosure? {
        var closure: PresentationCompletionClosure?
        
        switch configuration.presentationType {
            case .navigationController(type: .goBack):
                closure = self.defaultNavigationBackCompletionClosure(configuration: configuration)

            case .sheet(type: .dismiss, options: _):
                closure = self.defaultSheetDismissalCompletionClosure(configuration: configuration)
                
            default:
                closure = self.defaultCompletionClosure(configuration: configuration, destination: destination)
                
        }
        
        return closure
    }
    

}

extension ViewFlow: DestinationInterfaceCoordinatorDelegate {
    public func didRequestCurrentDestinationChange(newDestinationID: UUID) {

        if let presentedDestination = self.destination(for: newDestinationID), presentedDestination.id != currentDestination?.id {
            updateCurrentDestination(destination: presentedDestination)
        }
    }
}
