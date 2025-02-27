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
@MainActor public protocol NavigatingControllerDestinationable<PresentationConfiguration>: ControllerDestinationable, GroupedDestinationable where ControllerType: UINavigationController {
    
    /// Removes the current Destination and navigates to the previous Destination in the `UINavigationController` stack, if one exists.
    /// - Parameter previousPresentationID: An optional unique identifier of the previous Destination.
    func navigateBackInStack(presentationID: UUID?)
}

public extension NavigatingControllerDestinationable {
    
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
    }
    
    func addChild(childDestination: any Destinationable<PresentationConfiguration>, shouldSetDestinationAsCurrent: Bool? = true, shouldAnimate: Bool? = true) {
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
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>) {
        
        navigateBackInStack()
        addChild(childDestination: newDestination)
        
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
