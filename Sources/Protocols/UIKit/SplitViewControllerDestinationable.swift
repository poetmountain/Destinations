//
//  SplitViewControllerDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This protocol represents a Destination whose interface is a `UISplitViewController`.
public protocol SplitViewControllerDestinationable<DestinationType, ContentType, TabType>: GroupedControllerDestinationable  where ControllerType: UISplitViewController {
    
    ///  A dictionary of `UIViewController`-based Destination object identifiers, whose associated keys are the `UISplitViewController.Column` column type should be displayed in.
    var destinationIDsForColumns: [UISplitViewController.Column: UUID] { get set }
    
    /// Presents a Destination in a `UISplitViewController` column.
    ///
    /// - Note: This method will throw an error if the requested tab is not found.
    /// - Parameters:
    ///   - destination: A UIKit-based Destination to be presented.
    ///   - column: The column to present this Destination in.
    ///   - shouldUpdateSelectedColumn: Determines whether the column should become the current one.
    func presentDestination(destination: any ControllerDestinationable<DestinationType, ContentType, TabType>, in column: UISplitViewController.Column, shouldUpdateSelectedColumn: Bool, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?)
    
    /// Returns a column type if it finds a Destination identifier which matches the root Destination for that column.
    /// - Parameter destinationID: A Destination identifier representing the root Destination of a column.
    /// - Returns: A split view column type, if a matching Destination identifier was supplied.
    func column(destinationID: UUID) -> UISplitViewController.Column?
    
    /// Returns a column type that contains the specified Destination identifer in its view hierarchy.
    /// - Parameter destinationID: The identifier of the Destination to find.
    /// - Returns: A split view column type, if the Destination was found in the column's view hierarchy.
    func column(containing destinationID: UUID) -> UISplitViewController.Column?
    
    /// Returns the current Destination for the specified colunn. In the case where multiple Destinations are presented in a column, it will return the most recently-presented (visible) one.
    /// - Parameter column: The column type.
    /// - Returns: A `Controller`-based Destination, if one was found.
    func currentDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Returns the root Destination for the column. This is not necessarily the Destination representing the currently visible `UIViewController` class in a column, but is instead the `UIViewController` which is at the column's root level.
    ///
    /// This method should be used when building the column for a `UISplitViewController`.
    /// - Parameter column: The column type.
    /// - Returns: A Destination, if one was found.
    func rootDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
    
    /// Finds a Destination of the specified type within the children of this `UISplitViewController`.
    /// - Parameters:
    ///   - typeToFind: The type of Destination to find.
    ///   - currentLevel: The current level of the view hierarchy to search at.
    ///   - column: The column of the `UISplitViewController` to search in.
    /// - Returns: A Destination of the specified type, if one was found.
    func findDestination(typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>, column: UISplitViewController.Column) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)?
}

public extension SplitViewControllerDestinationable {
    
    func presentDestination(destination: any ControllerDestinationable<DestinationType, ContentType, TabType>, in column: UISplitViewController.Column, shouldUpdateSelectedColumn: Bool = true, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        DestinationsSupport.logger.log("Presenting controller \(destination.type) in splitview column \(column.rawValue).", level: .verbose)

        let controllerToPresent = destination.currentController()
                
        let currentColumnDestination = self.rootDestination(for: column)

        if shouldUpdateSelectedColumn {
            groupInternalState.currentChildDestination = destination
        }
        
        // If the current Destination is a NavigationStack, add the presented Destination to it
        // Otherwise replace the current View with the new one
        if let navDestination = currentColumnDestination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            addChild(childDestination: destination)
            destination.setParentID(id: navDestination.id)
            navDestination.addChild(childDestination: destination, shouldAnimate: true)
            
        } else if let currentColumnDestination {
            replaceChild(currentID: currentColumnDestination.id, with: destination, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
        } else {
            controller?.setViewController(controllerToPresent, for: column)
            addChild(childDestination: destination)
        }

        if destinationIDsForColumns[column] == nil {
            destinationIDsForColumns[column] = destination.id
        }
        
        destination.prepareForPresentation()

    }
    
    func updateChildren() {
        updateColumnControllers(columns: destinationIDsForColumns)
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<DestinationType, ContentType, TabType>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        
        guard let newDestination = newDestination as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let newController = newDestination.currentController() else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(newDestination.self)")
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
            
        }
        guard let controller, let currentIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == currentID }), let currentDestination = groupInternalState.childDestinations[safe: currentIndex] as? any ControllerDestinationable<DestinationType, ContentType, TabType>, let currentController = currentDestination.currentController(), let currentColumn = column(containing: currentID) else {
            let template = DestinationsSupport.errorMessage(for: .childDestinationNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
        }
  
        guard groupInternalState.childDestinations.contains(where: { $0.id == newDestination.id}) == false else {
            DestinationsSupport.logger.log("Destination of type \(newDestination.type) was already in childDestinations, could not replace child \(currentID).", category: .error)
            return
        }
        
        groupInternalState.childDestinations.insert(newDestination, at: currentIndex)
        newDestination.setParentID(id: id)
               
        if let childColumn = self.column(containing: currentID), let root = self.rootDestination(for: childColumn) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            if let navDestination = root as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
                // parent destination is a nav controller so tell it to remove the child
                removeChild(identifier: currentID, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
                
                navDestination.addChild(childDestination: newDestination, shouldAnimate: true)
                
            } else {
                // this is the main destination in the column so remove the column
                controller.setViewController(newController, for: childColumn)
                
            }
            
            groupInternalState.currentChildDestination = newDestination

            if destinationIDsForColumns[childColumn] == nil {
                destinationIDsForColumns[childColumn] = newDestination.id
            }
        }

    }
    
    func removeChild(identifier: UUID, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?) {
        
        guard let childColumn = self.column(containing: identifier), let childDestination = self.childForIdentifier(destinationIdentifier: identifier) else { return }
        
        DestinationsSupport.logger.log("Removing SplitViewController child \(childDestination.id) : \(childDestination.type)", level: .verbose)
        
        childDestination.cleanupResources()

        if let groupedChild = childDestination as? any GroupedDestinationable {
            groupedChild.removeAllChildren()
        }
        
        if let activeDestination = currentDestination(for: childColumn), let parentID = activeDestination.parentDestinationID(), let rootDestination = self.rootDestination(for: childColumn) as? any ControllerDestinationable {
            if let navController = rootDestination as? any NavigatingControllerDestinationable {
                // parent destination is a nav controller so tell it to remove the child
                navController.removeChild(identifier: identifier, removeDestinationFromFlowClosure: nil)

                if let lastDestination = navController.currentChildDestination() as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                    groupInternalState.currentChildDestination = lastDestination
                }
                
            } else if let splitViewController = currentController() as? any SplitViewControllerDestinationInterfacing, activeDestination.id == identifier {
                // this is the main destination in the column so remove the column
                splitViewController.setViewController(nil, for: childColumn)
                destinationIDsForColumns[childColumn] = nil
                groupInternalState.currentChildDestination = nil
            }
            
        }
        
        if let childIndex = groupInternalState.childDestinations.firstIndex(where: { $0.id == identifier }) {
            groupInternalState.childDestinations.remove(at: childIndex)
        } else {
            assertionFailure("Could not find child destination to remove")
            return
        }
        
        childDestination.removeAssociatedInterface()

        groupInternalState.childWasRemovedClosure?(identifier)
        
        groupInternalState.currentDestinationChangedClosure?(groupInternalState.currentChildDestination?.id)
        
        removeDestinationFromFlowClosure?(identifier)

    }
    
    func column(destinationID: UUID) -> UISplitViewController.Column? {
        return destinationIDsForColumns.first(where: { $0.value == destinationID })?.key
    }
    
    func column(containing destinationID: UUID) -> UISplitViewController.Column? {
        for column in destinationIDsForColumns.keys {
            if let activeDestination = self.currentDestination(for: column) {
                if activeDestination.id == destinationID {
                    return column
                }
                
                if let navDestination = activeDestination as? any NavigatingControllerDestinationable {
                    if navDestination.childForIdentifier(destinationIdentifier: destinationID) != nil {
                        return column
                    }
                }
                
                if let rootDestination = self.rootDestination(for: column), let navDestination = rootDestination as? any NavigatingControllerDestinationable, navDestination.childForIdentifier(destinationIdentifier: destinationID) != nil {
                    return column
                }
            }
        }
        
        return nil
    }
    
    func currentDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {

        if let currentID = destinationIDsForColumns[column], let destination = self.childForIdentifier(destinationIdentifier: currentID) as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
            if let navDestination = destination as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType>, let lastDestination = navDestination.currentChildDestination() as? any ControllerDestinationable<DestinationType, ContentType, TabType> {
                return lastDestination
            } else {
                return destination
            }
        }
        
        return nil
    }
    
    func rootDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        guard let destinationID = destinationIDsForColumns[column] else { return nil }
        
        return childForIdentifier(destinationIdentifier: destinationID) as? any ControllerDestinationable<DestinationType, ContentType, TabType>
    }
    
    func navigateBackInStack(presentationID: UUID? = nil) {

        guard let currentDestination = groupInternalState.currentChildDestination as? any ControllerDestinationable, let navController = currentDestination.currentController()?.navigationController as? UINavigationController else { return }
            
        DestinationsSupport.logger.log("splitview current dest from group state \(groupInternalState.currentChildDestination?.type)")

        
        navController.popViewController(animated: true)
        
        if let current = groupInternalState.currentChildDestination {
            groupInternalState.childDestinations.removeAll(where: { $0.id == current.id })
            groupInternalState.currentChildDestination = nil
            DestinationsSupport.logger.log("splitview child dests \(groupInternalState.childDestinations.map { $0.id })")

            // set new active child destination
            groupInternalState.currentChildDestination = groupInternalState.childDestinations.last
            
        }

    }
    
    func findDestination(typeToFind: DestinationType, currentLevel: any ControllerDestinationable<DestinationType, ContentType, TabType>, column: UISplitViewController.Column) -> (any ControllerDestinationable<DestinationType, ContentType, TabType>)? {
        
        if let parentID = currentLevel.parentDestinationID(), let parentDestination = childForIdentifier(destinationIdentifier: parentID) as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
            return parentDestination.findDestination(typeToFind: typeToFind, currentLevel: currentLevel)
        }
        
        if let current = currentDestination(for: column) {
            if current.type == typeToFind {
                return current
                
            } else if let navDestination = current as? any NavigatingControllerDestinationable<DestinationType, ContentType, TabType> {
                
                return navDestination.findDestination(typeToFind: typeToFind, currentLevel: current)
            }
        }
        
        return nil
    }
    
    /// Updates multiple Destinations in the specified columns. This is used internally by Destinations.
    /// - Parameters:
    ///   - columns: An dictionary of Destination identifiers whose keys are column types.
    internal func updateColumnControllers(columns: [UISplitViewController.Column: UUID]) {
        
        destinationIDsForColumns.removeAll()
        destinationIDsForColumns = columns
        
        for (type, destinationID) in columns {
            addContent(destinationID: destinationID, for: type)
        }
    }
    
    /// Adds a Destination to the specified column. This is used internally by Destinations.
    /// - Parameters:
    ///   - destinationID: The identifier of the Destination to add.
    ///   - column: The `UISplitViewController` column to add the Destination controller to.
    internal func addContent(destinationID: UUID, for column: UISplitViewController.Column) {

        if let childDestination = groupInternalState.childDestinations.first(where: { $0.id == destinationID }) as? any ControllerDestinationable, let childController = childDestination.currentController() {
            controller?.setViewController(childController, for: column)
        }
    }
    
    // default implementation
    func prepareForPresentation() {
        stateModel?.prepareForPresentation()
    }
}
