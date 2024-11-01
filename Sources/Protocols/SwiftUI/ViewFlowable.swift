//
//  ViewFlowable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This protocol represents a Flow which coordinates routing and navigation as a user moves through a SwiftUI-based app.
@MainActor public protocol ViewFlowable<PresentationConfiguration>: Flowable where InterfaceCoordinator == DestinationSwiftUICoordinator, PresentationConfiguration == DestinationPresentation<DestinationType, ContentType, TabType> {
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    
    /// A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    var destinationProviders: [DestinationType: any ViewDestinationProviding] { get set }

    /// Provides a Destination based on the provided configuration model.
    /// - Parameter configuration: The presentation configuration model describing the Destination to return.
    /// - Returns: The requested Destination, if one was found or able to be built.
    func destination(for configuration: PresentationConfiguration) -> (any ViewDestinationable<PresentationConfiguration>)?
    
    /// Builds and returns a new Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model to build the Destination.
    /// - Returns: The created Destination, if one could be built.
    func buildDestination(for configuration: PresentationConfiguration) -> (any ViewDestinationable<PresentationConfiguration>)?
        
    /// Presents a Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model by which to find or build a Destination.
    /// - Returns: The presented Destination, if one was found or created.
    @discardableResult func presentDestination(configuration: PresentationConfiguration) -> (any ViewDestinationable<PresentationConfiguration>)?
    
    /// Updates a presentation configuration model.
    /// - Parameters:
    ///   - configuration: A presentation configuration model to update.
    ///   - destination: A Destination to update.
    func updateDestinationConfiguration(configuration: inout PresentationConfiguration, destination: inout some ViewDestinationable<PresentationConfiguration>)
    
    /// Finds the closest navigator in the view hierarchy to the provided Destination.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a navigator, if one was found.
    func findNavigatorInViewHierarchy(searchDestination: any ViewDestinationable) -> (any DestinationPathNavigating)?
    
    /// Finds the closest Destination in the view hierarchy whose interface manages a `TabBar`.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a `TabBar` Destination, if found.
    func findTabBarInViewHierarchy(searchDestination: any ViewDestinationable) -> (any TabBarViewDestinationable<PresentationConfiguration, TabType>)?
    
    /// The default presentation closure run when a Destination is presented in the tab of a `TabView`.
    /// - Returns: A closure.
    func defaultTabBarPresentationClosure() -> ((_ destination: any ViewDestinationable<PresentationConfiguration>, _ tabViewID: UUID) -> Void)
}


public extension ViewFlowable {
    
    func buildDestination(for configuration: PresentationConfiguration) -> (any ViewDestinationable<PresentationConfiguration>)? where DestinationType == PresentationConfiguration.DestinationType, TabType == PresentationConfiguration.TabType {
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        var configuration = configuration
        let provider = destinationProviders[destinationType] as? any ViewDestinationProviding<PresentationConfiguration>
        
        if var destination = provider?.buildDestination(for: configuration, appFlow: self) as? any ViewDestinationable<PresentationConfiguration> {
            updateDestinationConfiguration(configuration: &configuration, destination: &destination)
            
            return destination
        } else {
            return nil
        }

    }
    

    @discardableResult func presentNextDestinationInQueue() -> (any Destinationable<PresentationConfiguration>)? {
        guard destinationQueue.count > 0 else { return nil }
        
        if let nextPresentation = destinationQueue.popFirst() {
            if let destinationType = nextPresentation.destinationType {
                DestinationsOptions.logger.log("⏭️ Presenting next queue \(destinationType).")
            }
            
            return presentDestination(configuration: nextPresentation)
        }
        return nil
    }
    
    
    func defaultSheetDismissalCompletionClosure(configuration: PresentationConfiguration) -> PresentationCompletionClosure? {
        
        return { [weak self, weak configuration] didComplete in
            guard let strongSelf = self, let configuration else { return }
            if didComplete {
                if let parentID = configuration.parentDestinationID, let parentDestination = strongSelf.destination(for: parentID) as? any ViewDestinationable<PresentationConfiguration> {

                    if let sheetID = configuration.actionTargetID {
                        strongSelf.removeDestination(destinationID: sheetID)
                    }
                    
                    strongSelf.updateCurrentDestination(destination: parentDestination)
                    parentDestination.isSystemNavigating = false
                    
                }
                
                strongSelf.uiCoordinator?.destinationToPresent = nil

                strongSelf.logDestinationPresented(configuration: configuration)

                strongSelf.presentNextDestinationInQueue()

            }
        }
        

    }
    
    func defaultNavigationBackCompletionClosure(configuration: PresentationConfiguration) -> PresentationCompletionClosure? {
        
        return { [weak self, weak configuration] didComplete in
            guard let strongSelf = self, let configuration else { return }

            if didComplete {
                DestinationsOptions.logger.log("✌️ Default system navigating back closure", level: .verbose)

                if let oldID = configuration.currentDestinationID {
                    strongSelf.removeDestination(destinationID: oldID)
                }
                
                if let currentID = configuration.actionTargetID, let targetDestination = strongSelf.destination(for: currentID) as? any ViewDestinationable<PresentationConfiguration> {
                    strongSelf.updateCurrentDestination(destination: targetDestination)
                    targetDestination.isSystemNavigating = false

                    strongSelf.logDestinationPresented(configuration: configuration)

                }
                
                strongSelf.uiCoordinator?.destinationToPresent = nil

                strongSelf.presentNextDestinationInQueue()

            }
        }
        
    }
    
    func defaultTabBarPresentationClosure() -> ((_ destination: any ViewDestinationable<PresentationConfiguration>, _ tabViewID: UUID) -> Void) {
        
        let closure =  { [weak self] (destination: any ViewDestinationable<PresentationConfiguration>, tabViewID: UUID) in
            guard let strongSelf = self else { return }
            guard let tabRootViewDestination = strongSelf.destination(for: tabViewID) as? any GroupedViewDestinationable<PresentationConfiguration>, let navigator = strongSelf.findNavigatorInViewHierarchy(searchDestination: tabRootViewDestination) else { return }
            
            if let navID = navigator.navigatorDestinationID, let navDestination = strongSelf.destination(for: navID) as? any GroupedDestinationable<PresentationConfiguration> {
                navDestination.addChild(childDestination: destination)
            }
        }
        
        return closure
    }
    
    func findNavigatorInViewHierarchy(searchDestination: any ViewDestinationable) -> (any DestinationPathNavigating)? {
        
        if let navDestination = searchDestination as? any NavigatingViewDestinationable, let navigator = navDestination.navigator() {
            return navigator
            
        } else if let parentID = searchDestination.parentDestinationID, let parent = self.destination(for: parentID) as? any ViewDestinationable {
            return findNavigatorInViewHierarchy(searchDestination: parent)
        }
        return nil
    }
    
    func findTabBarInViewHierarchy(searchDestination: any ViewDestinationable) -> (any TabBarViewDestinationable<PresentationConfiguration, TabType>)? {
        
        if let tabDestination = searchDestination as? any TabBarViewDestinationable<PresentationConfiguration, TabType> {
            return tabDestination
            
        } else if let parentID = searchDestination.parentDestinationID, let parent = self.destination(for: parentID) as? any ViewDestinationable {
            return findTabBarInViewHierarchy(searchDestination: parent)
        }
        return nil
    }

}


public extension ViewFlowable {
    
    /// A `ViewBuilder` method that returns a strongly-typed `View` associated with the specified Destiantion.
    /// - Parameter destinationID: The identifier of the Destination.
    /// - Returns: A strongly-typed `View` associated with the specified Destination.
    @ViewBuilder func destinationView(for destinationID: UUID) -> (some View)? {
        if let destination = destination(for: destinationID) as? any ViewDestinationable<PresentationConfiguration>, let view = destination.currentView() {
            
            AnyView(view)
        }
    }
    
    /// A `ViewBuilder` that returns a strongly-typed `View` associated with the Flow's starting Destination.
    /// - Returns: A strongly-typed `View` associated with the Flow's starting Destination.
    @ViewBuilder func startingDestinationView() -> (some View)? {
        if let destination = rootDestination as? any ViewDestinationable<PresentationConfiguration> {
            destinationView(for: destination.id)
        }
    }
}


public extension ViewFlowable {
    
    func updateDestinationConfiguration(configuration: inout PresentationConfiguration, destination: inout some ViewDestinationable<PresentationConfiguration>) {
        
        let currentDestination = currentDestination as? any ViewDestinationable<PresentationConfiguration>
        
        if case PresentationType.tabBar(tab: _) = configuration.presentationType {
            if let tabDestination = configuration.tabBarDestination {
                tabDestination.assignPresentationClosure(closure: self.defaultTabBarPresentationClosure())
            }
        }
        
        // subscribe to tab selection changes in order to update the current Destination
        if let tabDestination = destination as? any TabBarViewDestinationable<PresentationConfiguration, TabType> {
            tabDestination.assignSelectedTabUpdatedClosure { [weak self, weak tabDestination] selectedTab in
                if let selectedDestination = tabDestination?.currentDestination(for: selectedTab.type) {
                    tabDestination?.updateCurrentDestination(destinationID: selectedDestination.id)
                    self?.updateCurrentDestination(destination: selectedDestination)
                }
            }
        }
        
        // supply DestinationNavigating object
        if configuration.navigator == nil {
            if let currentDestination {
                configuration.navigator = findNavigatorInViewHierarchy(searchDestination: currentDestination)
                if case PresentationType.sheet(type: .dismiss, options: _) = configuration.presentationType {
                    configuration.shouldDelayCompletionActivation = true
                    configuration.navigator?.currentPresentationID = configuration.id
                }

            } else if let rootDestination = uiCoordinator?.rootView as? any NavigatingDestinationInterfacing {
                configuration.navigator = rootDestination.navigator
                if case PresentationType.sheet(type: .dismiss, options: _) = configuration.presentationType {
                    configuration.shouldDelayCompletionActivation = true
                    configuration.navigator?.currentPresentationID = configuration.id
                }

            }
        }
        

        destination.buildInterfaceActions { [weak self] configuration in
            guard let strongSelf = self else { return }
            strongSelf.presentDestination(configuration: configuration)
        }
        
        destination.buildInteractorActions { configuration in
        }
        
        destination.buildSystemNavigationActions { [weak self] configuration in
            guard let strongSelf = self else { return }
            strongSelf.presentDestination(configuration: configuration)
        }
    
        if configuration.actionType == .presentation {
            destination.updatePresentation(presentation: configuration)
        } else if configuration.actionType == .systemNavigation {
            destination.updateSystemNavigationPresentation(presentation: configuration)
        }
        
    }
    
}
