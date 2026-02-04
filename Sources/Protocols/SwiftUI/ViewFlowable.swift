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
@MainActor public protocol ViewFlowable<DestinationType, ContentType, TabType>: Flowable where InterfaceCoordinator == DestinationSwiftUICoordinator {
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    
    /// A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    var destinationProviders: [DestinationType: any ViewDestinationProviding] { get set }

    /// Provides a Destination based on the provided configuration model.
    /// - Parameter configuration: The presentation configuration model describing the Destination to return.
    /// - Returns: The requested Destination, if one was found or able to be built.
    func destination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ViewDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Builds and returns a new Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model to build the Destination.
    /// - Returns: The created Destination, if one could be built.
    func buildDestination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ViewDestinationable<DestinationType, ContentType, TabType>)?
        
    /// Presents a Destination based on the supplied configuration model.
    /// - Parameter configuration: A presentation configuration model by which to find or build a Destination.
    /// - Returns: The presented Destination, if one was found or created.
    @discardableResult func presentDestination(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ViewDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Updates a presentation configuration model.
    /// - Parameters:
    ///   - configuration: A presentation configuration model to update.
    ///   - destination: A Destination to update.
    func updateDestinationConfiguration(configuration: inout DestinationPresentation<DestinationType, ContentType, TabType>, destination: inout some ViewDestinationable<DestinationType, ContentType, TabType>)
    
    /// Finds the closest navigator in the view hierarchy to the provided Destination.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a navigator, if one was found.
    func findNavigatorInViewHierarchy(searchDestination: any ViewDestinationable) -> (any DestinationPathNavigating)?
    
    /// Finds the closest Destination in the view hierarchy whose interface is a `NavigationSplitView`.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a Destination, if one was found.
    func findSplitViewInViewHierarchy(currentDestination: any ViewDestinationable) -> (any NavigationSplitViewDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Finds the closest Destination in the view hierarchy whose interface manages a `TabBar`.
    /// - Parameter currentDestination: The Destination to start searching at.
    /// - Returns: Returns a `TabBar` Destination, if found.
    func findTabBarInViewHierarchy(searchDestination: any ViewDestinationable) -> (any TabBarViewDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Removes all Destinations higher in a UI stack until the specified type.
    /// - Parameter typeToFind: The type of Destination to stop the removal process at.
    func removeDestinationsBefore(nearest typeToFind: DestinationType)
    
    /// This method recursively removes parent Destinations until the supplied Destination type is found.
    /// - Parameters:
    ///   - destination: The Destination whose parent should be removed.
    ///   - type: The type of Destination to stop the removal process at.
    func removeParentDestination(for destination: any ViewDestinationable<DestinationType, ContentType, TabType>, until type: DestinationType)
    
    /// The default presentation closure run when a Destination is presented in the tab of a `TabView`.
    /// - Returns: A closure.
    func defaultTabBarPresentationClosure() -> ((_ destination: any ViewDestinationable<DestinationType, ContentType, TabType>, _ tabViewID: UUID) -> Void)
}


public extension ViewFlowable {
    
    func buildDestination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ViewDestinationable<DestinationType, ContentType, TabType>)? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        
        var configuration = configuration
        let provider = destinationProviders[destinationType] as? any ViewDestinationProviding<DestinationType, ContentType, TabType>
        
        if var destination = provider?.buildAndConfigureDestination(for: configuration, appFlow: self) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
            updateDestinationConfiguration(configuration: &configuration, destination: &destination)
                        
            return destination
        } else {
            return nil
        }

    }
    

    @discardableResult func presentNextDestinationInQueue(contentToPass: ContentType? = nil) -> (any Destinationable<DestinationType, ContentType, TabType>)? {
        guard destinationQueue.count > 0 else { return nil }
        
        if let nextPresentation = destinationQueue.popFirst() {
            if let destinationType = nextPresentation.destinationType {
                DestinationsSupport.logger.log("⏭️ Presenting next in queue: \(destinationType).")
            }
            
            if nextPresentation.contentType == nil {
                nextPresentation.contentType = contentToPass
            }
            
            return presentDestination(configuration: nextPresentation)
        }
        return nil
    }
    
    func presentDestinationPath(path: [DestinationPresentation<DestinationType, ContentType, TabType>], contentToPass: ContentType? = nil) {
        guard path.count > 0 else { return }

        destinationQueue = path
        
        let presentation = destinationQueue.first
        
        presentNextDestinationInQueue(contentToPass: contentToPass)
        
    }
    
    func removeDestinationsBefore(nearest typeToFind: DestinationType) {
        
        // make sure that there's another Destination of this type higher in the UI stack
        guard let firstDestination = activeDestinations.last(where: { $0.type == typeToFind && $0.id != currentDestination?.id }) else { return }
        
        if let current = self.currentDestination as? any ViewDestinationable<DestinationType, ContentType, TabType> {
            removeParentDestination(for: current, until: typeToFind)
        }
    }
    
    func removeParentDestination(for destination: any ViewDestinationable<DestinationType, ContentType, TabType>, until type: DestinationType) {
        
        DestinationsSupport.logger.log("Removing parent destination \(destination.type) :: id \(destination.id)", level: .verbose)

        if let parentID = destination.parentDestinationID(), let parentDestination = self.destination(for: parentID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
            
            if let navigationStackDestination = parentDestination as? NavigatingViewDestinationable<DestinationType, ContentType, TabType>, let navigator = navigationStackDestination.navigator() {
                
                if let target = navigationStackDestination.childDestinations().last(where: { $0.type == type && $0.id != destination.id }) {
                    // target is within the same navigation stack as current Destination
                    
                    let removedElements = navigator.backToElement(identifier: target.id)
                    
                    if removedElements.count >= 1 {
                        removeDestinations(destinationIDs: removedElements)
                    } else if removedElements.count == 1 {
                        navigationStackDestination.currentView()?.backToPreviousDestination(currentDestination: destination)
                    }

                } else {
                    // target isn't in the navigation stack, so remove all stack elements and we'll try to find it above the stack
                    let elementsToRemove = navigator.navigationPath
                    navigator.removeAll()
                    removeDestinations(destinationIDs: elementsToRemove)
                    
                    guard parentDestination.type != type else {
                        currentDestination = parentDestination
                        return
                    }
                    removeParentDestination(for: parentDestination, until: type)
                    
                }
            
                
            } else {
                removeDestination(destinationID: destination.id)
                
                guard destination.type != type else { return }
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
                    strongSelf.updateActiveDestinations(with: destination)
                }
                
                if let destination, let groupedDestination = destination as? any GroupedViewDestinationable<DestinationType, ContentType, TabType> {
                    let currentChildDestination = groupedDestination.currentChildDestination()
                    
                    if let parentDestinationID = destination.parentDestinationID(), let currentChildDestination, let parent = self?.destination(for: parentDestinationID) as? any GroupedViewDestinationable<DestinationType, ContentType, TabType>, (configuration.shouldSetDestinationAsCurrent == true || parent.supportsIgnoringCurrentDestinationStatus() == false) {
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
                    if let destination {
                        strongSelf.updateCurrentDestination(destination: destination)
                        strongSelf.logDestinationPresented(destination: destination, configuration: configuration)
                    } else {
                        strongSelf.currentDestination = strongSelf.activeDestinations.last
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
            if didComplete {
                if let parentID = configuration.parentDestinationID, let parentDestination = strongSelf.destination(for: parentID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {

                    if let sheetID = configuration.actionTargetID {
                        strongSelf.removeDestination(destinationID: sheetID)
                    }
                    
                    strongSelf.updateCurrentDestination(destination: parentDestination)
                    parentDestination.updateIsSystemNavigating(isNavigating: false)
                    
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
                    strongSelf.removeDestination(destinationID: oldID)
                }
                
                if let currentID = configuration.actionTargetID, let targetDestination = strongSelf.destination(for: currentID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                    strongSelf.updateCurrentDestination(destination: targetDestination)
                    targetDestination.updateIsSystemNavigating(isNavigating: false)

                    strongSelf.logDestinationPresented(configuration: configuration)

                }
                
                strongSelf.uiCoordinator?.destinationToPresent = nil

                strongSelf.presentNextDestinationInQueue()

            }
        }
        
    }
    
    func defaultTabBarPresentationClosure() -> ((_ destination: any ViewDestinationable<DestinationType, ContentType, TabType>, _ tabViewID: UUID) -> Void) {
        
        let closure =  { [weak self] (destination: any ViewDestinationable<DestinationType, ContentType, TabType>, tabViewID: UUID) in
            guard let strongSelf = self else { return }
            guard let tabRootViewDestination = strongSelf.destination(for: tabViewID) as? any GroupedViewDestinationable<DestinationType, ContentType, TabType>, let navigator = strongSelf.findNavigatorInViewHierarchy(searchDestination: tabRootViewDestination) else { return }
            
            if let navID = navigator.navigatorDestinationID, let navDestination = strongSelf.destination(for: navID) as? any GroupedViewDestinationable<DestinationType, ContentType, TabType> {
                navDestination.addChild(childDestination: destination)
            }
        }
        
        return closure
    }
    
    func findNavigatorInViewHierarchy(searchDestination: any ViewDestinationable) -> (any DestinationPathNavigating)? {
        
        if let navDestination = searchDestination as? any NavigatingViewDestinationable, let navigator = navDestination.navigator() {
            return navigator
            
        } else if let parentID = searchDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ViewDestinationable {
            return findNavigatorInViewHierarchy(searchDestination: parent)
        }
        return nil
    }
    
    func findSplitViewInViewHierarchy(currentDestination: any ViewDestinationable) -> (any NavigationSplitViewDestinationable<DestinationType, ContentType, TabType>)? {
        if let splitViewDestination = currentDestination as? any NavigationSplitViewDestinationable<DestinationType, ContentType, TabType> {
            return splitViewDestination
            
        } else if let parentID = currentDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
            return findSplitViewInViewHierarchy(currentDestination: parent)
        }
        return nil
    }
    
    func findTabBarInViewHierarchy(searchDestination: any ViewDestinationable) -> (any TabBarViewDestinationable<DestinationType, ContentType, TabType>)? {
        
        if let tabDestination = searchDestination as? any TabBarViewDestinationable<DestinationType, ContentType, TabType> {
            return tabDestination
            
        } else if let parentID = searchDestination.parentDestinationID(), let parent = self.destination(for: parentID) as? any ViewDestinationable {
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
        if let destination = destination(for: destinationID) as? any ViewDestinationable<DestinationType, ContentType, TabType>, let view = destination.currentView() {
            
            AnyView(view)
        }
    }
    
    /// A `ViewBuilder` that returns a strongly-typed `View` associated with the Flow's starting Destination.
    /// - Returns: A strongly-typed `View` associated with the Flow's starting Destination.
    @ViewBuilder func startingDestinationView() -> (some View)? {
        if let destination = rootDestination as? any ViewDestinationable<DestinationType, ContentType, TabType>, let view = destination.currentView() {
            let _ = DestinationsSupport.logger.log("Adding new root view \(destination.type) :: \(destination.id)", level: .verbose)
            
            destinationView(for: destination.id)
                .id(destination.id)
        }
    }
}


public extension ViewFlowable {
    
    func updateDestinationConfiguration(configuration: inout DestinationPresentation<DestinationType, ContentType, TabType>, destination: inout some ViewDestinationable<DestinationType, ContentType, TabType>) {
        
        let currentDestination = currentDestination as? any ViewDestinationable<DestinationType, ContentType, TabType>
        
        if case PresentationType.tabBar(tab: _) = configuration.presentationType {
            if let tabDestination = configuration.tabBarDestination {
                let closure = self.defaultTabBarPresentationClosure()
                tabDestination.assignPresentationClosure(closure: closure)
            }
        }
        
        // subscribe to tab selection changes in order to update the current Destination
        if let tabDestination = destination as? any TabBarViewDestinationable<DestinationType, ContentType, TabType> {
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

            } else if let rootView = uiCoordinator?.rootView as? any NavigatingDestinationInterfacing {
                configuration.navigator = rootView.destinationState.navigator
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
