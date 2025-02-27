//
//  NavigatingViewDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a type of Destination which manages a SwiftUI `NavigationStack`.
@MainActor public protocol NavigatingViewDestinationable<PresentationConfiguration>: ViewDestinationable, GroupedDestinationable where ViewType: NavigatingDestinationInterfacing {
    
    /// Removes the current Destination and navigates to the previous Destination in the stack, if one exists.
    /// - Parameter previousPresentationID: An optional unique identifier of the previous Destination.
    func navigateBackInStack(previousPresentationID: UUID?)
    
    /// Returns the navigator which manages the `NavigationStack`.
    func navigator() -> (any DestinationPathNavigating)?

}

public extension NavigatingViewDestinationable {
    
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
    }
    
    func addChild(childDestination: any Destinationable<PresentationConfiguration>, shouldSetDestinationAsCurrent: Bool? = true, shouldAnimate: Bool? = true) {
        DestinationsSupport.logger.log("Adding child \(childDestination.type) to NavigationStack \(childDestination.id)", level: .verbose)
        
        navigator()?.addPathElement(item: childDestination.id, shouldAnimate: shouldAnimate)
        groupInternalState.childDestinations.append(childDestination)
        // shouldSetDestinationAsCurrent is ignored for NavigationStacks because a new Destination should always become the current one
        groupInternalState.currentChildDestination = childDestination
        
        childDestination.setParentID(id: id)
        
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>) {

        navigateBackInStack()
        addChild(childDestination: newDestination)
        
    }
    
    func navigateBackInStack(previousPresentationID: UUID? = nil) {
        navigator()?.backToPreviousPathElement(previousPresentationID: previousPresentationID)
    }
    
    func navigator() -> (any DestinationPathNavigating)? {
        return view?.destinationState.navigator
    }
    
    func removeChild(identifier: UUID) {
        guard let childIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == identifier}), let childDestination = groupInternalState.childDestinations[safe: childIndex] else { return }
        
        DestinationsSupport.logger.log("Removing child \(childDestination.id) : \(childDestination.type)", level: .verbose)
        
        if let groupedChild = childDestination as? any GroupedDestinationable {
            groupedChild.removeAllChildren()
        }
        
        if let currentChildDestination = groupInternalState.currentChildDestination, childDestination.id == currentChildDestination.id {
            groupInternalState.currentChildDestination = nil
        }
        
        childDestination.cleanupResources()
        childDestination.removeAssociatedInterface()
        
        groupInternalState.childDestinations.remove(at: childIndex)

        // remove presentationID from navigator so that it doesn't create a false positive disappearance
        navigator()?.currentPresentationID = nil
        
        groupInternalState.childWasRemovedClosure?(identifier)
        
        // find and set new active child destination
        if let newCurrentID = navigator()?.navigationPath.last, let newCurrent = groupInternalState.childDestinations.first(where: { $0.id == newCurrentID }) {
            groupInternalState.currentChildDestination = newCurrent
        }
        
        groupInternalState.currentDestinationChangedClosure?(groupInternalState.currentChildDestination?.id)
    }
    
    // default implementation
    func prepareForPresentation() {
    }
}
