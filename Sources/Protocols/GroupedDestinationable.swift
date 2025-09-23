//
//  GroupedDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A closure run when a child Destination is removed from a ``GroupedDestinationable`` object.
public typealias GroupChildRemovedClosure = (_ destinationID: UUID) -> Void

/// A closure run when the current child Destination of a ``GroupedDestinationable`` has changed.
public typealias GroupCurrentDestinationChangedClosure = (_ destinationID: UUID?) -> Void

/// This abstract protocol represents a type of Destination which manages child Destinations, such as a `NavigationStack` in SwiftUI.
///
/// > Note: Protocols or classes that should take on group behavior should use ``GroupedViewDestinationable`` for SwiftUI projects and ``GroupedControllerDestinationable`` for UIKit projects.
@MainActor public protocol GroupedDestinationable<DestinationType, ContentType, TabType>: AnyObject {
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// The unique identifier for this Destination.
    var id: UUID { get }

    /// State object for handling functionality for the Destinations ecosystem.
    var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> { get set }
    
    /// Assigns a closure to be run when a child Destination is removed from this Group. This closure should be used by an associated Destination to respond to child removals that happened internally.
    /// - Parameter closure: A closure.
    func assignChildRemovedClosure(closure: @escaping GroupChildRemovedClosure)
    
    /// Assigns a closure to be run when the current child Destination has changed. This closure should be used by an associated Destination to respond to current Destination changes that happened internally.
    /// - Parameter closure: A closure.
    func assignCurrentDestinationChangedClosure(closure: @escaping GroupCurrentDestinationChangedClosure)

    /// Adds a child Destination to this group.
    /// - Parameter childDestination: A ``Destinationable`` object to add.
    /// - Parameter shouldSetDestinationAsCurrent: A Boolean which determines whether this Destination should become the current one.
    /// - Parameter shouldAnimate: A Boolean which determines whether this Destination should be animated when presented in the Group.
    func addChild(childDestination: any Destinationable<DestinationType, ContentType, TabType>, shouldSetDestinationAsCurrent: Bool?, shouldAnimate: Bool?)
    
    /// Removes a child Destination.
    /// - Parameter destinationIdentifier: The identifier of the Destination to remove.
    ///   - removeDestinationClosure: A closure that notifies an external object when this Destination has removed one of its children.
    ///   Typically this will be passed in when being called from a `DestinationPresentation` object, and handles the removal of the child Destination from the active Flow object. The identifier of the child that was removed should be passed in to the closure.
    func removeChild(identifier: UUID, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?)
    
    /// Removes all child Destinations from this group.
    func removeAllChildren()
    
    /// Returns the child Destination for the specified identifier.
    /// - Parameter destinationIdentifier: The identifier of the child Destination.
    /// - Returns: The child Destination, if one was found.
    func childForIdentifier(destinationIdentifier: UUID) -> (any Destinationable<DestinationType, ContentType, TabType>)?
    
    /// Replaces the child Destination that currently has focus.
    /// - Parameter newDestination: The new ``Destinationable`` object that should replace the current Destination referenced by ``currentChildDestination``.
    func replaceCurrentDestination(with newDestination: any Destinationable<DestinationType, ContentType, TabType>)
    
    /// Replaces the current child Destination.
    /// - Parameters:
    ///   - currentID: A `UUID` identifier matching the child Destination which should be replaced.
    ///   - newDestination: A ``Destinationable`` object to replace an existing child Destination.
    ///   - removeDestinationClosure: A closure that notifies an external object when this Destination has removed one of its children.
    ///   Typically this will be passed in when being called from a `DestinationPresentation` object, and handles the removal of the child Destination from the active Flow object. The identifier of the child that was removed should be passed in to the closure.
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?)
    
    /// Updates the currently active Destination with an identifier of another child.
    /// - Parameter destinationID: The Destination identifier to use. This Destination must be a current child.
    func updateCurrentDestination(destinationID: UUID)
    
    /// Provides a method for requesting the children of a Destination group be updated in some way.
    func updateChildren()

    /// Returns the child Destinations of this group.
    /// - Returns: The Destinations belonging to this gorup.
    func childDestinations() -> [any Destinationable<DestinationType, ContentType, TabType>]

    /// Returns the currently active child Destination.
    /// - Returns: The current child Destination.
    func currentChildDestination() -> (any Destinationable<DestinationType, ContentType, TabType>)?
    
    /// Determines whether this Destination supports the `shouldSetDestinationAsCurrent` parameter of the `addChild` method. If this Destination should ignore requests to not make added children the current Destination, this property should be set to `false`.
    /// - Returns: Returns whether the current Destination status should be ignored.
    func supportsIgnoringCurrentDestinationStatus() -> Bool
}

public extension GroupedDestinationable {
    
    func assignChildRemovedClosure(closure: @escaping GroupChildRemovedClosure) {
        groupInternalState.childWasRemovedClosure = closure
    }
    
    func assignCurrentDestinationChangedClosure(closure: @escaping GroupCurrentDestinationChangedClosure) {
        groupInternalState.currentDestinationChangedClosure = closure
    }
    
    func addChild(childDestination: any Destinationable<DestinationType, ContentType, TabType>, shouldSetDestinationAsCurrent: Bool? = true, shouldAnimate: Bool? = true) {
        groupInternalState.childDestinations.append(childDestination)
        childDestination.setParentID(id: id)
    }
    
    func replaceCurrentDestination(with newDestination: any Destinationable<DestinationType, ContentType, TabType>) {
        if let currentChildDestination = groupInternalState.currentChildDestination {
            replaceChild(currentID: currentChildDestination.id, with: newDestination)
        } else {
            addChild(childDestination: newDestination)
            updateCurrentDestination(destinationID: newDestination.id)
        }
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        guard let currentIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == currentID }) else { return }
        
        if groupInternalState.childDestinations.contains(where: { $0.id == newDestination.id}) == false {
            groupInternalState.childDestinations.insert(newDestination, at: currentIndex)
            newDestination.setParentID(id: id)
        }
        
        if groupInternalState.currentChildDestination?.id == currentID {
            groupInternalState.currentChildDestination = newDestination
        }
        
        removeChild(identifier: currentID, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)

    }
    
    func removeChild(identifier: UUID, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?) {
        guard let childIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == identifier}), let childDestination = groupInternalState.childDestinations[safe: childIndex] else { return }

        if let currentChildDestination = groupInternalState.currentChildDestination, childDestination.id == currentChildDestination.id {
            DestinationsSupport.logger.log("hey Removing current child \(currentChildDestination.type) from \(Self.self)", level: .verbose)
            groupInternalState.currentChildDestination = nil
        }
        
        DestinationsSupport.logger.log("Removing child \(identifier) from children array in \(Self.self)", level: .verbose)

        childDestination.cleanupResources()

        if let destination = childDestination as? any GroupedDestinationable<DestinationType, ContentType, TabType> {
            destination.removeAllChildren()
        }
        
        groupInternalState.childDestinations.remove(at: childIndex)
    
        childDestination.removeAssociatedInterface()

        groupInternalState.childWasRemovedClosure?(identifier)
        
        removeDestinationFromFlowClosure?(identifier)

    }
    
    func removeAllChildren() {
        for childDestination in groupInternalState.childDestinations.reversed() {
            removeChild(identifier: childDestination.id, removeDestinationFromFlowClosure: nil)
        }
    }
    
    func childForIdentifier(destinationIdentifier: UUID) -> (any Destinationable<DestinationType, ContentType, TabType>)? {
        return groupInternalState.childDestinations.first(where: { $0.id == destinationIdentifier })
    }
    
    func updateCurrentDestination(destinationID: UUID) {
        if let childDestination = groupInternalState.childDestinations.first(where: { $0.id == destinationID }) {
            groupInternalState.currentChildDestination = childDestination
        }
    }
    
    func childDestinations() -> [any Destinationable<DestinationType, ContentType, TabType>] {
        return groupInternalState.childDestinations
    }
    
    func currentChildDestination() -> (any Destinationable<DestinationType, ContentType, TabType>)? {
        return groupInternalState.currentChildDestination
    }
    
    func supportsIgnoringCurrentDestinationStatus() -> Bool {
        return groupInternalState.supportsIgnoringCurrentDestinationStatus
    }
    
    func updateChildren() {}
}
