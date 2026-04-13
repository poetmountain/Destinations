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
@MainActor public protocol ControllerFlowable<DestinationType, ContentType, TabType>: Flowable where InterfaceCoordinator == DestinationUIKitCoordinator {
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    
    /// A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    var destinationProviders: [DestinationType: any ControllerDestinationProviding] { get set }

    /// Provides a Destination based on the provided configuration model.
    /// - Parameter configuration: The presentation configuration model describing the Destination to return.
    /// - Returns: The requested Destination, if one was found or able to be built.
    func destination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Builds and returns a new Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model to build the Destination.
    /// - Returns: The created Destination, if one could be built.
    func buildDestination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Presents a Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model by which to find or build a Destination.
    /// - Returns: The presented Destination, if one was found or created.
    @discardableResult func presentDestination(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Updates a presentation configuration model.
    /// - Parameters:
    ///   - configuration: A presentation configuration model to update.
    ///   - destination: A Destination to update.
    func updateDestinationConfiguration(configuration: inout DestinationPresentation<DestinationType, ContentType, TabType>, destination: inout some ControllerDestinationable<DestinationType, ContentType, TabType>)
    
    /// Finds the closest Destination in the view hierarchy whose interface is a `UITabBarController`.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a Destination, if one was found.
    func findTabBarInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any TabBarControllerDestinationable<DestinationType, ContentType, TabType>)?

    /// Finds the closest navigator in the view hierarchy to the provided Destination.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a navigator, if one was found.
    func findNavigatorInViewHierarchy(searchDestination: any ControllerDestinationable) -> (any DestinationPathNavigating)?
    
    /// Finds the closest Destination in the view hierarchy whose interface is a `UISplitViewController`.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a Destination, if one was found.
    func findSplitViewInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any SplitViewControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Finds the closest navigator in the view hierarchy to the provided Destination.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a navigator, if one was found.
    func findNearestNavigatorInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any NavigatingControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Assigns a controller to serve as the base controller of this Flow's Destinations.
    /// - Parameter baseController: The root controller.
    func assignBaseController(_ baseController: any ControllerDestinationInterfacing)
    
    /// Assigns a root controller to serve as the base controller of this Flow's Destinations.
    /// - Parameter rootController: The root controller.
    @available(*, deprecated, renamed: "assignBaseController(_:)", message: "This method has been deprecated and will be removed in a future version. Please use the assignBaseController(_:) method instead.")
    func assignRoot(rootController: any ControllerDestinationInterfacing)
    
    
    /// Finds the nearest Destination of the specified type in the UI hierarchy.
    /// - Parameters:
    ///   - typeToFind: The type of Destination to find.
    ///   - currentLevel: The current hierarchy level to search at.
    /// - Returns: A Destination of the specified type, if one was found.
    func findNearestDestination(of typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// This method raises a runtime assert if any Routes in a Flow do not have a Provider assigned to them. It is called automatically by ``ControllerFlow``.
    func providersPreflight()
}

public extension ControllerFlowable {
    func buildDestination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        var configuration = configuration
        let provider = destinationProviders[destinationType] as? any ControllerDestinationProviding<DestinationType, ContentType, TabType>
        
        if var destination = provider?.buildAndConfigureDestination(for: configuration, appFlow: self) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            updateDestinationConfiguration(configuration: &configuration, destination: &destination)
            
            return destination
        } else {
            return nil
        }

    }
    
    func findTabBarInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any TabBarControllerDestinationable<DestinationType, ContentType, TabType>)? {
        if let tabDestination = currentDestination as? any TabBarControllerDestinationable<DestinationType, ContentType, TabType> {
            return tabDestination
            
        } else if let parentID = currentDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            return findTabBarInViewHierarchy(currentDestination: parent)
        }
        return nil
    }
    
    func findNavigatorInViewHierarchy(searchDestination: any ControllerDestinationable) -> (any DestinationPathNavigating)? {
        
        if let navDestination = searchDestination as? any NavigatingControllerDestinationable, let navigator = navDestination.navigator() {
            return navigator
            
        } else if let parentID = searchDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ControllerDestinationable {
            return findNavigatorInViewHierarchy(searchDestination: parent)
        }
        return nil
    }
    
    func findSplitViewInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any SplitViewControllerDestinationable<DestinationType, ContentType, TabType>)? {
        if let splitViewDestination = currentDestination as? any SplitViewControllerDestinationable<DestinationType, ContentType, TabType> {
            return splitViewDestination
            
        } else if let parentID = currentDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            return findSplitViewInViewHierarchy(currentDestination: parent)
        }
        return nil
    }
    
    func findNearestNavigatorInViewHierarchy(currentDestination: any ControllerDestinationable) -> (any NavigatingControllerDestinationable<DestinationType, ContentType, TabType>)? {
        
        if let controllerDestination = currentDestination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            return controllerDestination
            
        } else if let parentID = currentDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            return findNearestNavigatorInViewHierarchy(currentDestination: parent)
            
        } else if let parentController = currentDestination.currentController()?.parent as? any ControllerDestinationInterfacing, let parentDestination = parentController.destination() as? any ControllerDestinationable {
            return findNearestNavigatorInViewHierarchy(currentDestination: parentDestination)
        }
        return nil
        
    }

    @discardableResult func presentNextDestinationInQueue(contentToPass: ContentType? = nil) -> (any Destinationable<DestinationType, ContentType, TabType>)? {
        guard destinationQueue.count > 0 else {
            isPresentingDestinationPath = false
            return nil
        }
        
        isPresentingDestinationPath = true
        
        if let nextPresentation = destinationQueue.popFirst() {
            if let destinationType = nextPresentation.destinationType {
                DestinationsSupport.logger.log("⏭️ Presenting next queue \(destinationType).")
            }
            
            if nextPresentation.contentType == nil {
                nextPresentation.contentType = contentToPass
            }
            
            return presentDestination(configuration: nextPresentation)
        }
        return nil
    }
    
    func removeDestinationsBefore(nearest typeToFind: DestinationType) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        // make sure that there's another Destination of this type higher in the UI stack
        guard let current = self.currentDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let firstDestination = findNearestDestination(of: typeToFind, currentLevel: current) else { return nil }
        
        removeParentDestination(for: current, until: typeToFind)
        
        return firstDestination
    }
    
    func findNearestDestination(of typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        DestinationsSupport.logger.log("Find destination \(typeToFind) -- current level \(currentLevel.type)")

        if (currentLevel.type == typeToFind && currentLevel.id != self.currentDestination?.id) {
            return currentLevel
  
            
        } else if let parentDestinationID = currentLevel.parentDestinationID(), let parentDestination = self.destination(for: parentDestinationID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            
            if let tabDestination = parentDestination as? any TabBarControllerDestinationable<DestinationType, ContentType, TabType> {
                return tabDestination.findDestination(typeToFind: typeToFind, currentLevel: currentLevel)
                
            } else if let navDestination = parentDestination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
                return navDestination.findDestination(typeToFind: typeToFind, currentLevel: currentLevel)
                
            } else {
                return findNearestDestination(of: typeToFind, currentLevel: parentDestination)
            }
        }
        
        return nil
    }
    
    func removeParentDestination(for destination: any ControllerDestinationable<DestinationType, ContentType, TabType>, until type: DestinationType) {
        
        DestinationsSupport.logger.log("Removing parent destination \(destination.type) :: id \(destination.id)", level: .verbose)
        DestinationsSupport.logger.log("parent id \(destination.parentDestinationID())", level: .verbose)

        if let parentID = destination.parentDestinationID(), let parentDestination = self.destination(for: parentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            
            if let navigationStackDestination = parentDestination as? NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
                if let targetIndex = navigationStackDestination.childDestinations().lastIndex(where: { $0.type == type }) {
                    // target is within the same navigation stack as current Destination
                    
                    guard (targetIndex + 1 <= navigationStackDestination.childDestinations().count - 1) else { return }
                    
                    let removedElements = navigationStackDestination.childDestinations().suffix(from: targetIndex+1)
                    
                    
                    
                    DestinationsSupport.logger.log("Types to remove \(removedElements.map { $0.type })", level: .verbose)
                    
                    let removedElementIDs = removedElements.map(\.id)
                    
                    if removedElementIDs.count > 1 {
                        
                        print("destinations left \(navigationStackDestination.childDestinations().count) .... elements to remove \(removedElements.count)")
                        let remainingDestinations = Array(navigationStackDestination.childDestinations().dropLast(removedElements.count))
                        
                        print("remaining destinations \(remainingDestinations)")
                        

                        
                        removeDestinations(destinationIDs: removedElementIDs)
                        
                        if let remainingDestinations = remainingDestinations as? [any ControllerDestinationable<DestinationType, ContentType, TabType>] {
                            let remainingControllers = remainingDestinations.compactMap { $0.currentController() }
                            DestinationsSupport.logger.log("remaining controllers \(remainingControllers)", level: .verbose)

                            navigationStackDestination.currentController()?.setViewControllers(remainingControllers, animated: true)
                        }
                        
                        
                    } else if let currentChild = navigationStackDestination.currentChildDestination() as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                        currentChild.currentController()?.performSystemNavigationBack()
                    }
                    
                    
                } else {
                    // target isn't in the navigation stack, so remove all stack elements and we'll try to find it above the stack
                    let elementsToRemove = navigationStackDestination.childDestinations().map { $0.id }
                    removeDestinations(destinationIDs: elementsToRemove)
                    
                    guard parentDestination.type != type else { return }
                    removeParentDestination(for: parentDestination, until: type)
                    
                }

                
            } else {
                removeDestination(destinationID: destination.id)
                
                guard parentDestination.type != type else { return }
                removeParentDestination(for: parentDestination, until: type)
            }
            
        }
    }
    
    func defaultCompletionClosure(configuration: DestinationPresentation<DestinationType, ContentType, TabType>, destination: (any Destinationable<DestinationType, ContentType, TabType>)? = nil) -> PresentationCompletionClosure? {
        
        return { [weak self, weak configuration, weak destination] didComplete in
            guard let strongSelf = self else { return }
            guard let configuration else { return }
            
            
            if didComplete == true {
                DestinationsSupport.logger.log("✌️ Default presentation completion closure", level: .verbose)
                
                if let destination {
                    
                    // handle use case where the top-level Destination should be replaced
                    if configuration.presentationType == .replaceRoot {
                        strongSelf.replaceRootDestination(with: destination)
                        
                    } else if (configuration.presentationType == .replaceCurrent && strongSelf.activeDestinations.count == 0) {
                        strongSelf.rootDestination = destination
                    }
                    
                    strongSelf.updateActiveDestinations(with: destination)
                }
                
                if let destination, let groupedDestination = destination as? any GroupedControllerDestinationable<DestinationType, ContentType, TabType> {
                    let currentChildDestination = groupedDestination.currentChildDestination()
                    
                    if let parentDestinationID = destination.parentDestinationID(), let currentChildDestination, let parent = self?.destination(for: parentDestinationID) as? any GroupedControllerDestinationable<DestinationType, ContentType, TabType>, (configuration.shouldSetDestinationAsCurrent == true || parent.supportsIgnoringCurrentDestinationStatus() == false) {
                        // if this Destination's parent is also Group, add the Destination's current child as the Flow's current Destination
                        // as long as the parent allows this child Destination to take focus
                        strongSelf.updateCurrentDestination(destination: currentChildDestination)
                        
                    } else if let currentChildDestination {
                        // if this wasn't added to a Group and this Destination has a child, make that the current Flow Destination
                        strongSelf.updateCurrentDestination(destination: currentChildDestination)
                    } else {
                        // this Destination has no current child, so just make it the current Flow Destination
                        strongSelf.updateCurrentDestination(destination: destination)
                    }
                
                    for child in groupedDestination.childDestinations() {
                        strongSelf.updateActiveDestinations(with: child)
                    }
                    
                    groupedDestination.updateChildren()
                    
                    strongSelf.logDestinationPresented(destination: destination, configuration: configuration)
                    
                    strongSelf.uiCoordinator?.destinationToPresent = nil

                    strongSelf.presentNextDestinationInQueue(contentToPass: configuration.contentType)
                                        
                } else {
                    if let destination, destination.id != strongSelf.currentDestination?.id {
                        strongSelf.updateCurrentDestination(destination: destination)
                        strongSelf.logDestinationPresented(destination: destination, configuration: configuration)
                    }
                    
                    strongSelf.uiCoordinator?.destinationToPresent = nil

                    strongSelf.presentNextDestinationInQueue(contentToPass: configuration.contentType)

                }

            }
            
        }
    
    }
    
    
    func defaultSheetDismissalCompletionClosure(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> PresentationCompletionClosure? {
        
        return { [weak self, weak configuration] didComplete in
            guard let strongSelf = self, let configuration else { return }
            guard let sheetID = configuration.actionTargetID ?? configuration.currentDestinationID, let sheetDestination = strongSelf.destination(for: sheetID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> else { return }
            
            if didComplete {
                DestinationsSupport.logger.log("✌️ Default system sheet dismissal closure", level: .verbose)
                if let parentID = configuration.parentDestinationID, let targetDestination = strongSelf.destination(for: parentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                    strongSelf.updateCurrentDestination(destination: targetDestination)
                    
                    if let navigationDestination = strongSelf.findNearestNavigatorInViewHierarchy(currentDestination: sheetDestination) as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType>, let navController = navigationDestination.currentController() {
                                                
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
                
                if (sheetDestination.currentController()?.isBeingDismissed == false), let currentDestination = strongSelf.currentDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                    currentDestination.currentController()?.dismiss(animated: true) {
                    }
                }
                
                strongSelf.uiCoordinator?.destinationToPresent = nil
                
                strongSelf.logDestinationPresented(configuration: configuration)

                strongSelf.presentNextDestinationInQueue()

            }
        }
        

    }
    
    func defaultNavigationBackCompletionClosure(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> PresentationCompletionClosure? {
        
        return { [weak self, weak configuration] didComplete in
            guard let strongSelf = self, let configuration else { return }

            if didComplete {
                DestinationsSupport.logger.log("✌️ Default system navigating back closure", level: .verbose)

                if let oldID = configuration.currentDestinationID {
                    if let oldDestination = strongSelf.destination(for: oldID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                        oldDestination.prepareForDisappearance(wasVisible: true)
                    }
                    strongSelf.removeDestination(destinationID: oldID)
                }
                
                if let currentID = configuration.actionTargetID, let targetDestination = strongSelf.destination(for: currentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                    if currentID != strongSelf.currentDestination?.id {
                        strongSelf.updateCurrentDestination(destination: targetDestination)
                    }
                    targetDestination.updateIsSystemNavigating(isNavigating: false)
                    
                    
                    strongSelf.logDestinationPresented(configuration: configuration)

                }

                if let currentDestination = strongSelf.currentDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let navController = currentDestination.currentController() as? UINavigationController ?? currentDestination.currentController()?.navigationController {
                    
                    currentDestination.updateIsSystemNavigating(isNavigating: false)

                }
                
                strongSelf.uiCoordinator?.destinationToPresent = nil

                strongSelf.presentNextDestinationInQueue()

            }
        }
        
    }
}

public extension ControllerFlowable {
    
    
    func updateDestinationConfiguration(configuration: inout DestinationPresentation<DestinationType, ContentType, TabType>, destination: inout some ControllerDestinationable<DestinationType, ContentType, TabType>) {
                
        // subscribe to tab selection changes in order to update the current Destination
        if let tabDestination = destination as? any TabBarControllerDestinationable<DestinationType, ContentType, TabType> {
            tabDestination.assignSelectedTabUpdatedClosure { [weak self, weak tabDestination] selectedTab in
                if let selectedDestination = tabDestination?.currentDestination(for: selectedTab.type) {
                    tabDestination?.updateCurrentDestination(destinationID: selectedDestination.id)
                    self?.updateCurrentDestination(destination: selectedDestination)
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

public extension ControllerFlowable {
    
    func providersPreflight() {
        let registeredRoutes = Set(destinationProviders.keys.map(\.rawValue))
        let allRoutes = Set(DestinationType.allCases.map(\.rawValue))
        let missingRoutes = allRoutes.subtracting(registeredRoutes)
        
        assert(missingRoutes.count == 0, "📍⚠️ Flow has no Provider assigned for routes: \(missingRoutes).")
        
        // Tell each Provider to run internal preflight checks
        destinationProviders.values.forEach { $0.prepareForProviding() }
    }
}
