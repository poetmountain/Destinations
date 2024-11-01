//
//  ControllerFlowable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This protocol represents a Flow which coordinates routing and navigation as a user moves through a UIKit-based app.
@MainActor public protocol ControllerFlowable<PresentationConfiguration>: Flowable where InterfaceCoordinator == DestinationUIKitCoordinator, PresentationConfiguration == DestinationPresentation<DestinationType, ContentType, TabType> {
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    
    /// A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    var destinationProviders: [DestinationType: any ControllerDestinationProviding] { get set }

    /// Provides a Destination based on the provided configuration model.
    /// - Parameter configuration: The presentation configuration model describing the Destination to return.
    /// - Returns: The requested Destination, if one was found or able to be built.
    func destination(for configuration: PresentationConfiguration) -> (any ControllerDestinationable<PresentationConfiguration>)?
    
    /// Builds and returns a new Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model to build the Destination.
    /// - Returns: The created Destination, if one could be built.
    func buildDestination(for configuration: PresentationConfiguration) -> (any ControllerDestinationable<PresentationConfiguration>)?
    
    /// Presents a Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model by which to find or build a Destination.
    /// - Returns: The presented Destination, if one was found or created.
    @discardableResult func presentDestination(configuration: PresentationConfiguration) -> (any ControllerDestinationable<PresentationConfiguration>)?
    
    /// Updates a presentation configuration model.
    /// - Parameters:
    ///   - configuration: A presentation configuration model to update.
    ///   - destination: A Destination to update.
    func updateDestinationConfiguration(configuration: inout PresentationConfiguration, destination: inout some ControllerDestinationable<PresentationConfiguration>)
    
    /// Finds the closest navigator in the view hierarchy to the provided Destination.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a navigator, if one was found.
    func findTabBarInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any TabBarControllerDestinationable<PresentationConfiguration, TabType>)?
    
    /// Finds the closest Destination in the view hierarchy whose interface is a `UITabBarController`.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a `TabBar` Destination, if found.
    func findNearestNavigatorInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any NavigatingControllerDestinationable<PresentationConfiguration>)?
    
    /// Assigns a root controller to serve as the base controller of this Flow's Destinations.
    /// - Parameter rootController: The root controller.
    func assignRoot(rootController: any ControllerDestinationInterfacing)
}

public extension ControllerFlowable {
    func buildDestination(for configuration: PresentationConfiguration) -> (any ControllerDestinationable<PresentationConfiguration>)? where DestinationType == PresentationConfiguration.DestinationType, TabType == PresentationConfiguration.TabType {
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        var configuration = configuration
        let provider = destinationProviders[destinationType] as? any ControllerDestinationProviding<PresentationConfiguration>
        
        if var destination = provider?.buildDestination(for: configuration, appFlow: self) as? any ControllerDestinationable<PresentationConfiguration> {
            updateDestinationConfiguration(configuration: &configuration, destination: &destination)
            
            return destination
        } else {
            return nil
        }

    }
    
    func findTabBarInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any TabBarControllerDestinationable<PresentationConfiguration, TabType>)? {
        if let tabDestination = currentDestination as? any TabBarControllerDestinationable<PresentationConfiguration, TabType> {
            return tabDestination
            
        } else if let parentID = currentDestination.parentDestinationID, let parent = self.destination(for: parentID) as? any ControllerDestinationable<PresentationConfiguration> {
            return findTabBarInViewHierarchy(currentDestination: parent)
        }
        return nil
    }
    
    func findNearestNavigatorInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any NavigatingControllerDestinationable<PresentationConfiguration>)? {
        
        if let controllerDestination = currentDestination as? any NavigatingControllerDestinationable<PresentationConfiguration> {
            return controllerDestination
            
        } else if let parentID = currentDestination.parentDestinationID, let parent = self.destination(for: parentID) as? any ControllerDestinationable<PresentationConfiguration> {
            return findNearestNavigatorInViewHierarchy(currentDestination: parent)
            
        } else if let parentController = currentDestination.currentController()?.parent as? any ControllerDestinationInterfacing, let parentDestination = parentController.destination() as? any ControllerDestinationable {
            return findNearestNavigatorInViewHierarchy(currentDestination: parentDestination)
        }
        return nil
        
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
            guard let sheetID = configuration.actionTargetID ?? configuration.currentDestinationID, let sheetDestination = strongSelf.destination(for: sheetID) as? any ControllerDestinationable<PresentationConfiguration> else { return }
            
            if didComplete {
                DestinationsOptions.logger.log("✌️ Default system sheet dismissal closure", level: .verbose)
                if let parentID = configuration.parentDestinationID, let targetDestination = strongSelf.destination(for: parentID) as? any ControllerDestinationable<PresentationConfiguration> {
                    strongSelf.updateCurrentDestination(destination: targetDestination)
                    
                    if let navigationDestination = strongSelf.findNearestNavigatorInViewHierarchy(currentDestination: sheetDestination) as? any NavigatingControllerDestinationable<PresentationConfiguration>, let navController = navigationDestination.currentController() {
                                                
                        var destinationsToRemove: [UUID] = []
                        for controller in navController.viewControllers {
                            if let controller = controller as? any DestinationInterfacing {
                                let destinationID = controller.destination().id
                                destinationsToRemove.append(destinationID)
                            }
                        }
                        if destinationsToRemove.count > 0 {
                            strongSelf.removeDestinations(destinationIDs: destinationsToRemove)
                        }
                    }
                                            
                    strongSelf.removeDestination(destinationID: sheetID)
                    
                }
                
                if (sheetDestination.currentController()?.isBeingDismissed == false), let currentDestination = strongSelf.currentDestination as? any ControllerDestinationable<PresentationConfiguration> {
                    currentDestination.currentController()?.dismiss(animated: true) {
                    }
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
                
                if let currentID = configuration.actionTargetID, let targetDestination = strongSelf.destination(for: currentID) as? any ControllerDestinationable<PresentationConfiguration> {
                    strongSelf.updateCurrentDestination(destination: targetDestination)
                    targetDestination.isSystemNavigating = false
                    
                    // Because TabBarControllerDestinationable objects currently use raw UINavigationControllers to supply a navigation stack
                    // We have to manually update the tab bar's current Destination here
                    if let tabBar = self?.findTabBarInViewHierarchy(currentDestination: targetDestination) {
                        tabBar.updateCurrentDestination(destinationID: targetDestination.id)
                    }
                    
                    strongSelf.logDestinationPresented(configuration: configuration)

                }

                if let currentDestination = strongSelf.currentDestination as? any ControllerDestinationable<PresentationConfiguration>, let navController = currentDestination.currentController() as? UINavigationController ?? currentDestination.currentController()?.navigationController {
                    if navController.viewControllers.count > 1 {
                        navController.popViewController(animated: true)
                    } else {
                        navController.setViewControllers([], animated: true)
                    }
                    currentDestination.isSystemNavigating = false

                }
                
                strongSelf.uiCoordinator?.destinationToPresent = nil

                strongSelf.presentNextDestinationInQueue()

            }
        }
        
    }
}

public extension ControllerFlowable {
    
    
    func updateDestinationConfiguration(configuration: inout PresentationConfiguration, destination: inout some ControllerDestinationable<PresentationConfiguration>) {
                
        
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
