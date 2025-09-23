//
//  NavigatingControllerDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This protocol represents a Destination whose interface is a `UINavigationController`.
@MainActor public protocol NavigatingControllerDestinationable<DestinationType, ContentType, TabType>: GroupedControllerDestinationable where ControllerType: UINavigationController {
    
    /// Removes the current Destination and navigates to the previous Destination in the `UINavigationController` stack, if one exists.
    /// - Parameter previousPresentationID: An optional unique identifier of the previous Destination.
    func navigateBackInStack(presentationID: UUID?)
}

public extension NavigatingControllerDestinationable {
    
    /// Determines whether this Destination supports the `shouldSetDestinationAsCurrent` parameter of the `addChild` method. If this Destination should ignore requests to not make added children the current Destination, this property should be set to `false`. For `NavigatingControllerDestinationable`-conforming classes, the default is `false`.
    /// - Returns: Returns whether the current Destination status should be ignored.
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
    }
    
    func addChild(childDestination: any Destinationable<DestinationType, ContentType, TabType>, shouldSetDestinationAsCurrent: Bool? = true, shouldAnimate: Bool? = true) {
        DestinationsSupport.logger.log("Adding \(childDestination.type) as a child of navigation controller \(self.type).", level: .verbose)
        childDestination.setParentID(id: id)
        groupInternalState.childDestinations.append(childDestination)
        // shouldSetDestinationAsCurrent is ignored for NavigationControllers because a new Destination should always become the current one
        groupInternalState.currentChildDestination = childDestination

        if let newDestination = childDestination as? any ControllerDestinationable, let newController = newDestination.currentController() {
            let shouldAnimate = shouldAnimate ?? true
            controller?.pushViewController(newController, animated: shouldAnimate)
        }
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        
        navigateBackInStack()
        addChild(childDestination: newDestination)
        
        removeDestinationFromFlowClosure?(currentID)
    }
    
    func removeChild(identifier: UUID, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?) {
        guard let childIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == identifier}), let childDestination = groupInternalState.childDestinations[safe: childIndex] else { return }
        
        DestinationsSupport.logger.log("Removing NavigationStack child \(childDestination.id) : \(childDestination.type)", level: .verbose)
        
        childDestination.cleanupResources()

        if let groupedChild = childDestination as? any GroupedDestinationable {
            groupedChild.removeAllChildren()
        }
                
        groupInternalState.childDestinations.remove(at: childIndex)
        
        if let currentChildDestination = groupInternalState.currentChildDestination, childDestination.id == currentChildDestination.id {
            groupInternalState.currentChildDestination = nil
        }
        
        
        childDestination.removeAssociatedInterface()

        groupInternalState.childWasRemovedClosure?(identifier)
        
        // find and set new active child destination
        if let navController = self.currentController() as? UINavigationController, let lastController = navController.viewControllers.last as? any ControllerDestinationInterfacing, let lastDestination = lastController.destination() as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            navController.popViewController(animated: false)
            groupInternalState.currentChildDestination = lastDestination
        }
        
        groupInternalState.currentDestinationChangedClosure?(groupInternalState.currentChildDestination?.id)
        
        removeDestinationFromFlowClosure?(identifier)

    }
    
    func navigateBackInStack(presentationID: UUID? = nil) {
        guard let controller = controller as? UINavigationController else { return }
        
        controller.popViewController(animated: true)
        
        if let current = groupInternalState.currentChildDestination {
            groupInternalState.childDestinations.removeAll(where: { $0.id == current.id })
            groupInternalState.currentChildDestination = nil
            DestinationsSupport.logger.log("child dests \(groupInternalState.childDestinations.map { $0.id })")
            
            // set new active child destination
            groupInternalState.currentChildDestination = groupInternalState.childDestinations.last
            
        }
    }
    
    // default implementation
    func prepareForPresentation() {
    }
    
}
