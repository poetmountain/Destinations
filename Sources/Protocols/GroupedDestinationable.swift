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

/// This protocol represents a type of Destination which manages child Destinations, such as a `NavigationStack` in SwiftUI.
@MainActor public protocol GroupedDestinationable<PresentationConfiguration>: AnyObject {
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// An enum which defines available Destination presentation types. Typically this is ``DestinationPresentationType``.
    associatedtype PresentationType: DestinationPresentationTypeable
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    associatedtype PresentationConfiguration: DestinationPresentationConfiguring<DestinationType, TabType, ContentType>

    /// The unique identifier for this Destination.
    var id: UUID { get }

    /// An array of the child Destinations this object manages.
    var childDestinations: [any Destinationable<PresentationConfiguration>] { get set }
    
    /// The child Destination which currently has focus within this Destination's children.
    var currentChildDestination: (any Destinationable<PresentationConfiguration>)? { get set }
    
    /// Determines whether this Destination supports the `shouldSetDestinationAsCurrent` parameter of the `addChild` method. If this Destination should ignore requests to not make added children the current Destination, this property should be set to `false`.
    var supportsIgnoringCurrentDestinationStatus: Bool { get }
    
    /// A closure run when a child Destination is removed from this Group.
    var childWasRemovedClosure: GroupChildRemovedClosure? { get set }
    
    /// A closure run when the current child Destination has changed.
    var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure? { get set }
    
    
    /// Assigns a closure to be run when a child Destination is removed from this Group.
    /// - Parameter closure: A closure.
    func assignChildRemovedClosure(closure: @escaping GroupChildRemovedClosure)
    
    /// Assigns a closure to be run when the current child Destination has changed.
    /// - Parameter closure: A closure.
    func assignCurrentDestinationChangedClosure(closure: @escaping GroupCurrentDestinationChangedClosure)

    /// Adds a child Destination to this group.
    /// - Parameter childDestination: A ``Destinationable`` object to add.
    /// - Parameter shouldSetDestinationAsCurrent: A Boolean which determines whether this Destination should become the current one.
    func addChild(childDestination: any Destinationable<PresentationConfiguration>, shouldSetDestinationAsCurrent: Bool?)
    
    /// Removes a child Destination.
    /// - Parameter destinationIdentifier: The identifier of the Destination to remove.
    func removeChild(identifier: UUID)
    
    /// Removes all child Destinations from this group.
    func removeAllChildren()
    
    /// Returns the child Destination for the specified identifier.
    /// - Parameter destinationIdentifier: The identifier of the child Destination.
    /// - Returns: The child Destination, if one was found.
    func childForIdentifier(destinationIdentifier: UUID) -> (any Destinationable<PresentationConfiguration>)?
    
    /// Replaces the child Destination that currently has focus.
    /// - Parameter newDestination: The new ``Destinationable`` object that should replace the current Destination referenced by ``currentChildDestination``.
    func replaceCurrentDestination(with newDestination: any Destinationable<PresentationConfiguration>)
    
    /// Replaces the current child Destination.
    /// - Parameters:
    ///   - currentID: A `UUID` identifier matching the child Destination which should be replaced.
    ///   - newDestination: A ``Destinationable`` object to replace an existing child Destination.
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>)
    
    /// Updates the currently active Destination with an identifier of another child.
    /// - Parameter destinationID: The Destination identifier to use. This Destination must be a current child.
    func updateCurrentDestination(destinationID: UUID)
    
    /// Provides a method for requesting the children of a Destination group be updated in some way.
    func updateChildren()
    

}

public extension GroupedDestinationable {
    
    func assignChildRemovedClosure(closure: @escaping GroupChildRemovedClosure) {
        childWasRemovedClosure = closure
    }
    
    func assignCurrentDestinationChangedClosure(closure: @escaping GroupCurrentDestinationChangedClosure) {
        currentDestinationChangedClosure = closure
    }
    
    func addChild(childDestination: any Destinationable<PresentationConfiguration>, shouldSetDestinationAsCurrent: Bool? = true) {
        childDestinations.append(childDestination)
        childDestination.parentDestinationID = id
    }
    
    func replaceCurrentDestination(with newDestination: any Destinationable<PresentationConfiguration>) {
        if let currentChildDestination {
            replaceChild(currentID: currentChildDestination.id, with: newDestination)
        } else {
            addChild(childDestination: newDestination)
            updateCurrentDestination(destinationID: newDestination.id)
        }
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>) {
        guard let currentIndex = childDestinations.firstIndex(where: { $0.id == currentID }) else { return }
        
        if childDestinations.contains(where: { $0.id == newDestination.id}) == false {
            childDestinations.insert(newDestination, at: currentIndex)
            newDestination.parentDestinationID = id
        }
        
        if currentChildDestination?.id == currentID {
            currentChildDestination = newDestination
        }
        
        removeChild(identifier: currentID)

    }
    
    func removeChild(identifier: UUID) {
        guard let childIndex = childDestinations.firstIndex(where: { $0.id == identifier}), let childDestination = childDestinations[safe: childIndex] else { return }

        if let currentChildDestination, childDestination.id == currentChildDestination.id {
            DestinationsOptions.logger.log("Removing current child \(identifier) from \(Self.self)", level: .verbose)
            self.currentChildDestination = nil
        }
        
        DestinationsOptions.logger.log("Removing child \(identifier) from children array in \(Self.self)", level: .verbose)

        childDestinations.remove(at: childIndex)
    
        childWasRemovedClosure?(identifier)
    }
    
    func removeAllChildren() {
        for childDestination in self.childDestinations {
            removeChild(identifier: childDestination.id)
        }
    }
    
    func childForIdentifier(destinationIdentifier: UUID) -> (any Destinationable<PresentationConfiguration>)? {
        return childDestinations.first(where: { $0.id == destinationIdentifier })
    }
    
    func updateCurrentDestination(destinationID: UUID) {
        if let childDestination = childDestinations.first(where: { $0.id == destinationID }) {
            currentChildDestination = childDestination
        }
    }
    
    func updateChildren() {}
}

/// A typealias describing a SwiftUI-based ``GroupedDestinationable`` which also conforms to ``ViewDestinationable``.
public typealias GroupedViewDestinationable<PresentationConfiguration: DestinationPresentationConfiguring> = GroupedDestinationable<PresentationConfiguration> & ViewDestinationable<PresentationConfiguration>

/// A typealias describing a UIKit-based ``GroupedDestinationable`` which also conforms to ``ControllerDestinationable``.
public typealias GroupedControllerDestinationable<PresentationConfiguration: DestinationPresentationConfiguring> = GroupedDestinationable<PresentationConfiguration> & ControllerDestinationable<PresentationConfiguration>
