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
@MainActor public protocol NavigatingControllerDestinationable<DestinationType, ContentType, TabType>: GroupedControllerDestinationable where ControllerType: NavigationControllerDestinationInterfacing {
    
    /// Returns the navigator which manages the state of the `UINavigationController` stack.
    func navigator() -> (any DestinationPathNavigating)?
    
    /// Removes the current Destination and navigates to the previous Destination in the `UINavigationController` stack, if one exists.
    /// - Parameter previousPresentationID: An optional unique identifier of the previous Destination.
    func navigateBackInStack(presentationID: UUID?)
    
    /// Finds a Destination of the specified type within the `UINavigationController` stack.
    /// - Parameters:
    ///   - typeToFind: The type of Destination to find.
    ///   - currentLevel: The current level of the view hierarchy to search at.
    /// - Returns: A Destination of the specified type, if one was found.
    func findDestination(typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
}

public extension NavigatingControllerDestinationable {
    
    /// Determines whether this Destination supports the `shouldSetDestinationAsCurrent` parameter of the `addChild` method. If this Destination should ignore requests to not make added children the current Destination, this property should be set to `false`. For `NavigatingControllerDestinationable`-conforming classes, the default is `false`.
    /// - Returns: Returns whether the current Destination status should be ignored.
    var supportsIgnoringCurrentDestinationStatus: Bool {
        return false
    }
    
    func addChild(childDestination: any Destinationable<DestinationType, ContentType, TabType>, shouldSetDestinationAsCurrent: Bool? = true, shouldAnimate: Bool? = true) {
        DestinationsSupport.logger.log("Adding \(childDestination.type) as a child of navigation controller \(self.type).", level: .verbose)
        
        navigator()?.addPathElement(item: childDestination.id, shouldAnimate: shouldAnimate)

        childDestination.setParentID(id: id)
        groupInternalState.childDestinations.append(childDestination)
        // shouldSetDestinationAsCurrent is ignored for NavigationControllers because a new Destination should always become the current one
        groupInternalState.currentChildDestination = childDestination
        
        if let newDestination = childDestination as? any ControllerDestinationable, let newController = newDestination.currentController() {
            let shouldAnimate = shouldAnimate ?? true
            controller?.pushViewController(newController, animated: shouldAnimate)
        }
    }
    
    func removeDestinations(destinations: [any ControllerDestinationable<DestinationType, ContentType, TabType>]) {
        
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        
        navigateBackInStack()
        addChild(childDestination: newDestination)
        
        removeDestinationFromFlowClosure?(currentID)
    }
    
    func removeAllChildren() {
        
        navigator()?.removeAll()

        for childDestination in groupInternalState.childDestinations.reversed() {
            removeChild(identifier: childDestination.id, removeDestinationFromFlowClosure: nil)
        }
    }
    
    func removeChild(identifier: UUID, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?) {
        guard let childIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == identifier}), let childDestination = groupInternalState.childDestinations[safe: childIndex] else { return }
        
        DestinationsSupport.logger.log("Removing NavigationStack child \(childDestination.id) : \(childDestination.type)", level: .verbose)
        
        // remove presentationID from navigator so that it doesn't create a false positive disappearance
        navigator()?.currentPresentationID = nil
        
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
        if let newCurrentID = navigator()?.navigationPath.last, let newCurrent = groupInternalState.childDestinations.first(where: { $0.id == newCurrentID }) {
            groupInternalState.currentChildDestination = newCurrent
        }
                
        groupInternalState.currentDestinationChangedClosure?(groupInternalState.currentChildDestination?.id)
        
        removeDestinationFromFlowClosure?(identifier)

    }
    
    func navigator() -> (any DestinationPathNavigating)? {
        return controller?.destinationState.navigator
    }
    
    func navigateBackInStack(presentationID: UUID? = nil) {
        guard let controller = controller as? UINavigationController else { return }
        
        navigator()?.backToPreviousPathElement(previousPresentationID: presentationID)

        controller.popViewController(animated: true)
        
        if let current = groupInternalState.currentChildDestination {
            groupInternalState.childDestinations.removeAll(where: { $0.id == current.id })
            groupInternalState.currentChildDestination = nil
            
            // set new active child destination
            groupInternalState.currentChildDestination = groupInternalState.childDestinations.last
            
        }
    }
    
    func findDestination(typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {

        guard let navigationPath = navigator()?.navigationPath, let currentIndex = navigationPath.lastIndex(where: { $0 == currentLevel.id }) else { return nil }
        
        
        let pathSlice = navigationPath.prefix(upTo: currentIndex)
        
        for element in pathSlice.reversed() {
            if let destination = self.childForIdentifier(destinationIdentifier: element) as? any ControllerDestinationable<DestinationType, ContentType, TabType>, destination.type == typeToFind {
                return destination
            }
        }
        
        return nil
    }
    
    // default implementation
    func prepareForPresentation() {
        stateModel?.prepareForPresentation()
    }

}
