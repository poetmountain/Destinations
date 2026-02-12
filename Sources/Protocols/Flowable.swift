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
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// A type of object that coordinates the presentation of a Destination within a UI framework.
    associatedtype InterfaceCoordinator: DestinationInterfaceCoordinating
    
    /// The currently presented Destination object.
    var currentDestination: (any Destinationable<DestinationType, ContentType, TabType>)? { get set }
    
    /// An array of the active Destination objects. These are Destinations which have been presented and currently exist in the app's user interface, even if they are not currently visible on screen.
    var activeDestinations: [any Destinationable<DestinationType, ContentType, TabType>] { get set }
    
    /// The ``DestinationInterfaceCoordinating`` object which coordinates the presentation of new Destinations within the app's user interface.
    var uiCoordinator: InterfaceCoordinator? { get set }
    
    /// The root Destination of the user interface this Flow manages.
    var rootDestination: (any Destinationable<DestinationType, ContentType, TabType>)? { get set }
    
    /// A queue of Destination presentations to be presented in serial order, used with the ``presentDestinationPath`` method.
    var destinationQueue: [DestinationPresentation<DestinationType, ContentType, TabType>] { get set }
    
    /// Represents whether a sequence of Destination presentations are currently being presented from the ``destinationpath`` presentation type.
    var isPresentingDestinationPath: Bool { get set }
    
    /// Starts the presentation of the Destination defined by the `startingDestination` configuration object.
    func start()
    
    /// Returns the Destination object associated with an identifier.
    /// - Parameter destinationID: A `UUID` identifier of the Destination to return.
    /// - Returns: A ``Destinationable`` object, if one is found.
    func destination(for destinationID: UUID) -> (any Destinationable<DestinationType, ContentType, TabType>)?

    /// Updates a stored Destination with a new one matching its identifier.
    /// - Parameter destination: A ``Destinationable`` object to replace the current one with.
    func updateDestination(destination: any Destinationable<DestinationType, ContentType, TabType>)
    
    /// Updates the currently presented Destination stored in ``currentDestination``.
    /// - Parameter destination: The new current Destination.
    func updateCurrentDestination(destination: any Destinationable<DestinationType, ContentType, TabType>)
    
    /// Adds a new Destination to the ``activeDestinations`` array.
    /// - Parameter destination: The ``Destinationable`` object to add.
    func updateActiveDestinations(with destination: any Destinationable<DestinationType, ContentType, TabType>)
    
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
    
    /// Replaces the current root Destination with the supplied Destination.
    /// - Parameters:
    ///   - newDestination: The Destination which should be the new root.
    func replaceRootDestination(with newDestination: any Destinationable<DestinationType, ContentType, TabType>)
    
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
    func defaultCompletionClosure(configuration: DestinationPresentation<DestinationType, ContentType, TabType>, destination: (any Destinationable<DestinationType, ContentType, TabType>)?) -> PresentationCompletionClosure?
    
    /// Returns the default completion closure that is activated when a currently presented UI sheet was dismissed.
    /// - Parameter configuration: The presentation configuration object associated with this action.
    /// - Returns: A completion closure.
    func defaultSheetDismissalCompletionClosure(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> PresentationCompletionClosure?
    
    /// Returns the default completion closure that is activated when a UI navigation path has moved back to the previous Destination.
    /// - Parameter configuration: The presentation configuration object associated with this action.
    /// - Returns: A completion closure.
    func defaultNavigationBackCompletionClosure(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> PresentationCompletionClosure?
    
    /// Presents a nested path of Destination objects, displaying them serially within the user interface.
    ///
    /// ## Discussion
    /// This method can be used to provide deep links into an app's interface.
    ///
    /// - Parameter path: An array of presentation configuration objects. The order of the configuration objects in the array determines the order in which their associated Destinations will be presented.
    func presentDestinationPath(path: [DestinationPresentation<DestinationType, ContentType, TabType>], contentToPass: ContentType?)
    
    /// Presents the next Destination in the ``destinationQueue`` array, if one exists.
    /// - Returns: The newly presented Destination, if any configuration objects were left in the queue.
    @discardableResult func presentNextDestinationInQueue(contentToPass: ContentType?) -> (any Destinationable<DestinationType, ContentType, TabType>)?
    
    /// Returns a closure to run when a presentation has completed.
    /// - Parameters:
    ///   - configuration: A presentation configuration model to use with the closure.
    ///   - destination: The Destination being presented. This is not used with system navigation events.
    /// - Returns: The presentation closure.
    func presentationCompletionClosure(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>, destination: (any Destinationable<DestinationType, ContentType, TabType>)?) -> PresentationCompletionClosure?
    
    /// Logs the type of Destination presentation.
    /// - Parameters:
    ///   - destination: The Destination that was presented.
    ///   - configuration: The presentation configuration model associated with this presentation.
    func logDestinationPresented(destination: (any Destinationable<DestinationType, ContentType, TabType>)?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>)
}

public extension Flowable {
    
    func destination(for destinationID: UUID) -> (any Destinationable<DestinationType, ContentType, TabType>)? {
        return activeDestinations.first(where: { $0.id == destinationID })
    }
    
    func updateCurrentDestination(destination: any Destinationable<DestinationType, ContentType, TabType>) {
        uiCoordinator?.destinationToPresent = nil
 
        let isPreviousFinal = (isPresentingDestinationPath == false)
        currentDestination?.prepareForDisappearance(wasVisible: isPreviousFinal)
        
        currentDestination = destination
        
        let isFinalDestination = destinationQueue.count == 0
        destination.prepareForAppearance(isVisible: isFinalDestination)
        
        DestinationsSupport.logger.log("🔄 Updated current destination to \(destination.type).")
    }
    
    func updateDestination(destination: any Destinationable<DestinationType, ContentType, TabType>) {
        if let destinationIndex = activeDestinations.firstIndex(where: { $0.id == destination.id }) {
            activeDestinations[destinationIndex] = destination
        }
    }
    
    func updateActiveDestinations(with destination: any Destinationable<DestinationType, ContentType, TabType>) {
        guard self.destination(for: destination.id) == nil else { return }
        activeDestinations.append(destination)
        DestinationsSupport.logger.log("Active destinations \(activeDestinations.map { $0.type }).", level: .verbose)

    }
    
    func presentDestinationPath(path: [DestinationPresentation<DestinationType, ContentType, TabType>], contentToPass: ContentType? = nil) {
        
        guard path.count > 0 else {
            isPresentingDestinationPath = false
            return
        }
                
        destinationQueue = path
        
        // By default, navigation controller push animations are turned off for path presentations
        for presentation in destinationQueue {
            if presentation.navigationStackOptions == nil {
                let navigationOptions = NavigationStackPresentationOptions(shouldAnimate: false)
                presentation.navigationStackOptions = navigationOptions
            }
        }
        
        presentNextDestinationInQueue(contentToPass: contentToPass)

    }
    
    func removeDestination(destinationID: UUID) {

        guard let destination = self.destination(for: destinationID) else { return }
                
        destination.cleanupResources()
        destination.removeAssociatedInterface()

        if currentDestination?.id == destinationID {
            currentDestination = nil
        }
        
        if rootDestination?.id == destinationID {
            rootDestination = nil
        }
        
        if let destination = destination as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType> {
            let children = destination.childDestinations().reversed().map { $0.id }
            removeDestinations(destinationIDs: children)
            destination.removeAllChildren()
            
        } else if let destination = destination as? any TabBarViewDestinationable<DestinationType, ContentType, TabType> {
            let children = destination.childDestinations().reversed().map { $0.id }
            removeDestinations(destinationIDs: children)
            destination.removeAllChildren()
            
        } else if let destination = destination as? any GroupedViewDestinationable<DestinationType, ContentType, TabType> {
            let children = destination.childDestinations().reversed().map { $0.id }
            removeDestinations(destinationIDs: children)
            destination.removeAllChildren()
            
        } else if let destination = destination as? any GroupedControllerDestinationable<DestinationType, ContentType, TabType> {
            let children = destination.childDestinations().reversed().map { $0.id }
            removeDestinations(destinationIDs: children)
            destination.removeAllChildren()
        }
        
        // if this Destination's parent is a Group, tell it to remove the child from itself
        if let parentID = destination.parentDestinationID(), let parent = self.destination(for: parentID) as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType> {
            parent.removeChild(identifier: destinationID, removeDestinationFromFlowClosure: nil)
            
        } else if let parentID = destination.parentDestinationID(), let parent = self.destination(for: parentID) as? any TabBarViewDestinationable<DestinationType, ContentType, TabType> {
            parent.removeChild(identifier: destinationID, removeDestinationFromFlowClosure: nil)
            
        } else if let parentID = destination.parentDestinationID(), let parent = self.destination(for: parentID) as? any GroupedViewDestinationable<DestinationType, ContentType, TabType> {
            parent.removeChild(identifier: destinationID, removeDestinationFromFlowClosure: nil)
            
        } else if let parentID = destination.parentDestinationID(), let parent = self.destination(for: parentID) as? any GroupedControllerDestinationable<DestinationType, ContentType, TabType> {
            parent.removeChild(identifier: destinationID, removeDestinationFromFlowClosure: nil)
        }
                    
        if let index = activeDestinations.firstIndex(where: { $0.id == destinationID }) {
            activeDestinations.remove(at: index)
        }


        DestinationsSupport.logger.log("Active destinations (after removal) \(activeDestinations.map { $0.type }).", level: .verbose)
    }
    
    func removeDestinations(destinationIDs: [UUID]) {
        for destinationID in destinationIDs {
            removeDestination(destinationID: destinationID)
        }
    }
    
    func replaceRootDestination(with newDestination: any Destinationable<DestinationType, ContentType, TabType>) {
        for activeDestination in activeDestinations.reversed() {
            removeDestination(destinationID: activeDestination.id)
        }

        rootDestination = newDestination
    }
    
    func activateCompletionClosure(for destinationID: UUID, presentationID: UUID, didComplete: Bool, isSystemNavigationAction: Bool = false) {
        
        if let destination = self.destination(for: destinationID) as? any Destinationable<DestinationType, ContentType, TabType> {
            
            var presentation: DestinationPresentation<DestinationType, ContentType, TabType>?
            
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
    

    func logDestinationPresented(destination: (any Destinationable<DestinationType, ContentType, TabType>)? = nil, configuration: DestinationPresentation<DestinationType, ContentType, TabType>) {
        if let destinationType = destination?.type {
            DestinationsSupport.logger.log("✅ New destination \(destinationType) was presented in \(configuration.presentationType).")
        } else if let currentDestination {
            DestinationsSupport.logger.log("✅ Existing destination \(currentDestination.type) presented with \(configuration.presentationType). Action type: \(configuration.actionType)")
        } else {
            DestinationsSupport.logger.log("✅ No destination presented with \(configuration.presentationType). Action type: \(configuration.actionType)")
        }
    }
    
}
