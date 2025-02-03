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
public protocol SplitViewControllerDestinationable<PresentationConfiguration>: ControllerDestinationable, GroupedDestinationable  where ControllerType: UISplitViewController {
    
    ///  A dictionary of `UIViewController`-based Destination object identifiers, whose associated keys are the `UISplitViewController.Column` column type should be displayed in.
    var destinationIDsForColumns: [UISplitViewController.Column: UUID] { get set }
    
    /// Presents a Destination in a `UISplitViewController` column.
    ///
    /// - Note: This method will throw an error if the requested tab is not found.
    /// - Parameters:
    ///   - destination: A UIKit-based Destination to be presented.
    ///   - column: The column to present this Destination in.
    ///   - shouldUpdateSelectedColumn: Determines whether the column should become the current one.
    func presentDestination(destination: any ControllerDestinationable<PresentationConfiguration>, in column: UISplitViewController.Column, shouldUpdateSelectedColumn: Bool, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?)
    
    /// Returns a column type if it finds a Destination identifier which matches the root Destination for that column.
    /// - Parameter destinationID: A Destination identifier representing the root Destination of a column.
    /// - Returns: A split view column type, if a matching Destination identifier was supplied.
    func column(destinationID: UUID) -> UISplitViewController.Column?
    
    /// Returns the current Destination for the specified colunn. In the case where multiple Destinations are presented in a column, it will return the most recently-presented (visible) one.
    /// - Parameter column: The column type.
    /// - Returns: A `Controller`-based Destination, if one was found.
    func currentDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<PresentationConfiguration>)?
    
    /// Returns the root Destination for the column. This is not necessarily the Destination representing the currently visible `UIViewController` class in a column, but is instead the `UIViewController` which is at the column's root level.
    ///
    /// This method should be used when building the column for a `UISplitViewController`.
    /// - Parameter column: The column type.
    /// - Returns: A Destination, if one was found.
    func rootDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<PresentationConfiguration>)?
}

public extension SplitViewControllerDestinationable {
    
    func presentDestination(destination: any ControllerDestinationable<PresentationConfiguration>, in column: UISplitViewController.Column, shouldUpdateSelectedColumn: Bool = true, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        DestinationsSupport.logger.log("Presenting controller \(destination.type) in splitview column \(column.rawValue).", level: .verbose)

        let controllerToPresent = destination.currentController()
                
        controller?.setViewController(controllerToPresent, for: column)
        addChild(childDestination: destination)
        
        if shouldUpdateSelectedColumn {
            currentChildDestination = destination
        }

    }
    
    func updateChildren() {
        updateColumnControllers(columns: destinationIDsForColumns)
    }
    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        
        guard let newDestination = newDestination as? any ControllerDestinationable<PresentationConfiguration>, let newController = newDestination.currentController() else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(newDestination.self)")
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
            
        }
        guard let controller, let currentIndex = childDestinations.firstIndex(where: { $0.id == currentID }), let currentDestination = childDestinations[safe: currentIndex] as? any ControllerDestinationable<PresentationConfiguration>, let currentController = currentDestination.currentController(), let currentColumn = column(destinationID: currentID) else {
            let template = DestinationsSupport.errorMessage(for: .childDestinationNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
        }
  
        guard childDestinations.contains(where: { $0.id == newDestination.id}) == false else {
            DestinationsSupport.logger.log("Destination of type \(newDestination.type) was already in childDestinations, could not replace child \(currentID).", category: .error)
            return
        }
        
        childDestinations.insert(newDestination, at: currentIndex)
        newDestination.parentDestinationID = id
        destinationIDsForColumns[currentColumn] = newDestination.id
               
        controller.setViewController(newController, for: currentColumn)
        
        if let column = self.column(destinationID: currentID), let newDestination = newDestination as? any ControllerDestinationable, let newController = newDestination.currentController() {
            currentController.navigationController?.setViewControllers([controller], animated: false)

        }
           
        removeChild(identifier: currentID, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)

        currentChildDestination = newDestination

    }
    
    func column(destinationID: UUID) -> UISplitViewController.Column? {
        return destinationIDsForColumns.first(where: { $0.value == destinationID })?.key
    }
    
    func currentDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<PresentationConfiguration>)? {

        if let splitViewController = self.currentController(), let columnController = splitViewController.viewController(for: column), let visibleController = columnController.navigationController?.visibleViewController as? any ControllerDestinationInterfacing {
            return visibleController.destination() as? any ControllerDestinationable<PresentationConfiguration>
        }
        
        return nil
    }
    
    func rootDestination(for column: UISplitViewController.Column) -> (any ControllerDestinationable<PresentationConfiguration>)? {
        guard let destinationID = destinationIDsForColumns[column] else { return nil }
        
        return childForIdentifier(destinationIdentifier: destinationID) as? any ControllerDestinationable<PresentationConfiguration>
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

        if let childDestination = childDestinations.first(where: { $0.id == destinationID }) as? any ControllerDestinationable, let childController = childDestination.currentController() {
            controller?.setViewController(childController, for: column)
        }
    }
}
