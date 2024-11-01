//
//  Flowable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A closure that is activated when a Destination presentation has completed.
public typealias PresentationCompletionClosure = ((_ didComplete: Bool) -> Void)

/// This protocol represents Flow objects which coordinate routing, navigation, and the management of Destination objects as a user moves through an app's interface.
///
/// Flows manage the creation, appearance, and removal of Destinations as a user navigates through the app. They are the single source of truth for what Destinations currently exist in the ecosystem. Typically you don't interact with them directly after they've been configured. In most cases you can use one of the provided `ViewFlow` or `ControllerFlow` classes for SwiftUI and UIKit apps respectively.
@MainActor public protocol Flowable: AnyObject, Observable {
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring<DestinationType, TabType, ContentType>
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// A type of object that coordinates the presentation of a Destination within a UI framework.
    associatedtype InterfaceCoordinator: DestinationInterfaceCoordinating
    
    /// The currently presented Destination object.
    var currentDestination: (any Destinationable<PresentationConfiguration>)? { get set }
    
    /// An array of the active Destination objects. These are Destinations which have been presented and currently exist in the app's user interface, even if they are not currently visible on screen.
    var activeDestinations: [any Destinationable<PresentationConfiguration>] { get set }
    
    /// The ``DestinationInterfaceCoordinating`` object which coordinates the presentation of new Destinations within the app's user interface.
    var uiCoordinator: InterfaceCoordinator? { get set }
    
    /// The root Destination of the user interface this Flow manages.
    var rootDestination: (any Destinationable<PresentationConfiguration>)? { get set }
    
    /// A queue of Destination presentations to be presented in serial order, used with the ``presentDestinationPath`` method.
    var destinationQueue: [PresentationConfiguration] { get set }
    
    /// Starts the presentation of the Destination defined by the `startingDestination` configuration object.
    func start()
    
    /// Returns the Destination object associated with an identifier.
    /// - Parameter destinationID: A `UUID` identifier of the Destination to return.
    /// - Returns: A ``Destinationable`` object, if one is found.
    func destination(for destinationID: UUID) -> (any Destinationable<PresentationConfiguration>)?

    /// Updates a stored Destination with a new one matching its identifier.
    /// - Parameter destination: A ``Destinationable`` object to replace the current one with.
    func updateDestination(destination: any Destinationable<PresentationConfiguration>)
    
    /// Updates the currently presented Destination stored in ``currentDestination``.
    /// - Parameter destination: The new current Destination.
    func updateCurrentDestination(destination: any Destinationable<PresentationConfiguration>)
    
    /// Adds a new Destination to the ``activeDestinations`` array.
    /// - Parameter destination: The ``Destinationable`` object to add.
    func updateActiveDestinations(with destination: any Destinationable<PresentationConfiguration>)
    
    /// Removes a Destination and any of its children.
    ///
    /// > Note: If this is the current Destination, ``currentDestination`` will become nil.
    /// - Parameter destinationID: The identifier of the Destination to remove.
    func removeDestination(destinationID: UUID)
    
    /// Removes multiple Destinations and any of their children.
    ///
    /// > Note: If one of these Destinations is the current one, ``currentDestination`` will become nil.
    /// - Parameter destinationIDs: An array of identifiers for the Destinations to remove.
    func removeDestinations(destinationIDs: [UUID])
    
    /// Activates a presentation completion closure corresponding to the specified Destination and presentation identifiers.
    /// - Parameters:
    ///   - destinationID: The identifier of the Destination the closure is associated with.
    ///   - presentationID: The identifier of the presentation configuration object the closure is associated with.
    ///   - didComplete: A Boolean indicating whether the presentation completed successfully.
    ///   - isSystemNavigationAction: A Boolean indicating whether this is a system navigation action.
    func activateCompletionClosure(for destinationID: UUID, presentationID: UUID, didComplete: Bool, isSystemNavigationAction: Bool)
    
    /// Returns the default completion closure that is activated when a Destination presentation has completed.
    /// - Parameters:
    ///   - configuration: The presentation configuration object.
    ///   - destination: The ``Destinationable`` object which was presented.
    /// - Returns: A completion closure.
    func defaultCompletionClosure(configuration: PresentationConfiguration, destination: any Destinationable<PresentationConfiguration>) -> PresentationCompletionClosure?
    
    /// Returns the default completion closure that is activated when a currently presented UI sheet was dismissed.
    /// - Parameter configuration: The presentation configuration object associated with this action.
    /// - Returns: A completion closure.
    func defaultSheetDismissalCompletionClosure(configuration: PresentationConfiguration) -> PresentationCompletionClosure?
    
    /// Returns the default completion closure that is activated when a UI navigation path has moved back to the previous Destination.
    /// - Parameter configuration: The presentation configuration object associated with this action.
    /// - Returns: A completion closure.
    func defaultNavigationBackCompletionClosure(configuration: PresentationConfiguration) -> PresentationCompletionClosure?
    
    /// Presents a nested path of Destination objects, displaying them serially within the user interface.
    ///
    /// ## Discussion
    /// This method can be used to provide deep links into an app's interface.
    ///
    /// - Parameter path: An array of presentation configuration objects. The order of the configuration objects in the array determines the order in which their associated Destinations will be presented.
    func presentDestinationPath(path: [PresentationConfiguration])
    
    /// Presents the next Destination in the ``destinationQueue`` array, if one exists.
    /// - Returns: The newly presented Destination, if any configuration objects were left in the queue.
    @discardableResult func presentNextDestinationInQueue() -> (any Destinationable<PresentationConfiguration>)?
    
    /// Returns a closure to run when a presentation has completed.
    /// - Parameters:
    ///   - configuration: A presentation configuration model to use with the closure.
    ///   - destination: The Destination being presented. This is not used with system navigation events.
    /// - Returns: The presentation closure.
    func presentationCompletionClosure(for configuration: PresentationConfiguration, destination: (any Destinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)?) -> PresentationCompletionClosure?
    
    /// Logs the type of Destination presentation.
    /// - Parameters:
    ///   - destination: The Destination that was presented.
    ///   - configuration: The presentation configuration model associated with this presentation.
    func logDestinationPresented(destination: (any Destinationable<PresentationConfiguration>)?, configuration: PresentationConfiguration)
}

public extension Flowable {
    
    func destination(for destinationID: UUID) -> (any Destinationable<PresentationConfiguration>)? {
        return activeDestinations.first(where: { $0.id == destinationID })
    }
    
    func updateCurrentDestination(destination: any Destinationable<PresentationConfiguration>) {
        uiCoordinator?.destinationToPresent = nil
        currentDestination = destination
        DestinationsOptions.logger.log("🔄 Updated current destination to \(destination.type).")
    }
    
    func updateDestination(destination: any Destinationable<PresentationConfiguration>) {
        if let destinationIndex = activeDestinations.firstIndex(where: { $0.id == destination.id }) {
            activeDestinations[destinationIndex] = destination
        }
    }
    
    func updateActiveDestinations(with destination: any Destinationable<PresentationConfiguration>) {
        guard self.destination(for: destination.id) == nil else { return }
        activeDestinations.append(destination)
        DestinationsOptions.logger.log("Active destinations \(activeDestinations.map { $0.type }).", level: .verbose)

    }
    
    func presentDestinationPath(path: [PresentationConfiguration]) {
        
        destinationQueue = path
        
        let nextDestination = presentNextDestinationInQueue()
        
        if rootDestination == nil {
            rootDestination = nextDestination
        }
    }
    
    func removeDestination(destinationID: UUID) {
        if (currentDestination?.id == destinationID) {
            currentDestination = nil
        }
        
        if let destination = self.destination(for: destinationID) {
            destination.cleanupResources()
            destination.removeAssociatedInterface()
            
            if let destination = destination as? any GroupedDestinationable<PresentationConfiguration> {
                let children = destination.childDestinations.map { $0.id }
                removeDestinations(destinationIDs: children)
                destination.removeAllChildren()
            }
            
            // if this Destination's parent is a Group, tell it to remove the child from itself
            if let parentID = destination.parentDestinationID, let parent = self.destination(for: parentID) as? any GroupedDestinationable<PresentationConfiguration> {
                parent.removeChild(identifier: destinationID)
            }

            activeDestinations.removeAll(where: { $0.id == destinationID })

        }

        DestinationsOptions.logger.log("Active destinations (after removal) \(activeDestinations.map { $0.type }).", level: .verbose)
    }
    
    func removeDestinations(destinationIDs: [UUID]) {
        for destinationID in destinationIDs {
            removeDestination(destinationID: destinationID)
        }        
    }
    
    
    func activateCompletionClosure(for destinationID: UUID, presentationID: UUID, didComplete: Bool, isSystemNavigationAction: Bool = false) {
        
        if let destination = self.destination(for: destinationID) as? any Destinationable<PresentationConfiguration> {
            
            var presentation: PresentationConfiguration?
            
            if isSystemNavigationAction {
                presentation = destination.systemNavigationPresentation(presentationID: presentationID)
            } else {
                presentation = destination.presentation(presentationID: presentationID)
            }
            
            if let presentation, presentation.shouldDelayCompletionActivation == true {
                presentation.completionClosure?(didComplete)
            }
        }
        
    }
    
    func defaultCompletionClosure(configuration: PresentationConfiguration, destination: any Destinationable<PresentationConfiguration>) -> PresentationCompletionClosure? {
        
        return { [weak self, weak configuration, weak destination] didComplete in
            guard let strongSelf = self else { return }
            guard let destination else { return }
            guard let configuration else { return }
            
            if didComplete {
                DestinationsOptions.logger.log("✌️ Default presentation completion closure", level: .verbose)
      
                strongSelf.updateActiveDestinations(with: destination)
            
                if let groupedDestination = destination as? any GroupedDestinationable<PresentationConfiguration> {
                    let currentChildDestination = groupedDestination.currentChildDestination
                    
                    if let parentDestinationID = destination.parentDestinationID, let currentChildDestination, let parent = self?.destination(for: parentDestinationID) as? any GroupedDestinationable<PresentationConfiguration>, (configuration.shouldSetDestinationAsCurrent == true || parent.supportsIgnoringCurrentDestinationStatus == false) {
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
                
                    for child in groupedDestination.childDestinations {
                        strongSelf.updateActiveDestinations(with: child)
                    }
                    
                    groupedDestination.updateChildren()
                    
                    strongSelf.logDestinationPresented(destination: destination, configuration: configuration)
                    
                    strongSelf.uiCoordinator?.destinationToPresent = nil

                    strongSelf.presentNextDestinationInQueue()
                                        
                } else {
                    strongSelf.updateCurrentDestination(destination: destination)

                    strongSelf.logDestinationPresented(destination: destination, configuration: configuration)

                    strongSelf.uiCoordinator?.destinationToPresent = nil

                    strongSelf.presentNextDestinationInQueue()

                }

            }
            
        }
    
    }
    

    func logDestinationPresented(destination: (any Destinationable<PresentationConfiguration>)? = nil, configuration: PresentationConfiguration) {
        if let destinationType = destination?.type {
            DestinationsOptions.logger.log("✅ New destination \(destinationType) was presented in \(configuration.presentationType).")
        } else if let currentDestination {
            DestinationsOptions.logger.log("✅ Existing destination \(currentDestination.type) presented with \(configuration.presentationType). Action type: \(configuration.actionType)")
        } else {
            DestinationsOptions.logger.log("✅ No destination presented with \(configuration.presentationType). Action type: \(configuration.actionType)")
        }
    }
    
}
