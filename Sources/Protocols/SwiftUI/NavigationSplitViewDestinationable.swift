//
//  NavigationSplitViewDestinationable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This protocol represents a Destination whose interface `View` handles a `NavigationSplitView`.
@MainActor public protocol NavigationSplitViewDestinationable<PresentationConfiguration>: ViewDestinationable, GroupedDestinationable where ViewType: NavigationSplitViewDestinationInterfacing {
    
    ///  A dictionary of `View`-based Destination object identifiers, whose associated keys are the `NavigationSplitViewColumn` column type should be displayed in.
    var destinationIDsForColumns: [NavigationSplitViewColumn: UUID] { get set }
    
    /// A reference to the `View` currently used in the `sidebar` column of this Destination's associated `NavigationSplitView`. This property is updated when a new `View` is presented in the column.
    ///
    /// To implement this in your `View` and enable dynamic updating of your `NavigationSplitView`'s column, bind this property from inside the `sidebar` column's closure using a ``BindableContainerView``.
    ///
    /// Example:
    /// ```swift
    /// NavigationSplitView(columnVisibility: $columnVisibility) {
    ///     BindableContainerView(content: $destinationState.destination.currentSidebar)
    /// } content: {
    ///     BindableContainerView(content: $destinationState.destination.currentContent)
    /// } detail: {
    ///     BindableContainerView(content: $destinationState.destination.currentDetail)
    /// }
    /// ```
    var currentSidebar: ContainerView<AnyView> { get set }
    
    /// A reference to the `View` currently used in the `content` column of this Destination's associated `NavigationSplitView`. This property is updated when a new `View` is presented in the column.
    ///
    /// To implement this in your `View` and enable dynamic updating of your `NavigationSplitView`'s column, bind this property from inside the `content` column's closure using a ``BindableContainerView``.
    ///
    /// Example:
    /// ```swift
    /// NavigationSplitView(columnVisibility: $columnVisibility) {
    ///     BindableContainerView(content: $destinationState.destination.currentSidebar)
    /// } content: {
    ///     BindableContainerView(content: $destinationState.destination.currentContent)
    /// } detail: {
    ///     BindableContainerView(content: $destinationState.destination.currentDetail)
    /// }
    /// ```
    var currentContent: ContainerView<AnyView> { get set }
    
    /// A reference to the `View` currently used in the `detail` column of this Destination's associated `NavigationSplitView`. This property is updated when a new `View` is presented in the column.
    ///
    /// To implement this in your `View` and enable dynamic updating of your `NavigationSplitView`'s column, bind this property from inside the `detail` column's closure using a ``BindableContainerView``.
    ///
    /// Example:
    /// ```swift
    /// NavigationSplitView(columnVisibility: $columnVisibility) {
    ///     BindableContainerView(content: $destinationState.destination.currentSidebar)
    /// } content: {
    ///     BindableContainerView(content: $destinationState.destination.currentContent)
    /// } detail: {
    ///     BindableContainerView(content: $destinationState.destination.currentDetail)
    /// }
    /// ```
    var currentDetail: ContainerView<AnyView> { get set }

    /// Presents a Destination in a `NavigationSplitView` column.
    ///
    /// - Note: This method will throw an error if the requested column is not found.
    /// - Parameters:
    ///   - destination: A SwiftUI-based Destination to be presented.
    ///   - column: The column to present this Destination in.
    ///   - shouldUpdateSelectedColumn: Determines whether the column should become the current one.
    func presentDestination(destination: any ViewDestinationable<PresentationConfiguration>, in column: NavigationSplitViewColumn, shouldUpdateSelectedColumn: Bool, presentationOptions: NavigationStackPresentationOptions?, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure?)
    
    /// Returns a column type if it finds a Destination identifier which matches the root Destination for that column.
    /// - Parameter destinationID: A Destination identifier representing the root Destination of a column.
    /// - Returns: A split view column type, if a matching Destination identifier was supplied.
    func column(destinationID: UUID) -> NavigationSplitViewColumn?
    
    /// Returns the current Destination for the specified colunn. In the case where multiple Destinations are presented in a column, it will return the most recently-presented (visible) one.
    /// - Parameter column: The column type.
    /// - Returns: A `View`-based Destination, if one was found.
    func currentDestination(for column: NavigationSplitViewColumn) -> (any ViewDestinationable<PresentationConfiguration>)?
    
    /// Returns the root Destination for the column. This is not necessarily the Destination representing the currently visible `View` in a column, but is instead the `View` which is at the column's root level, such as a `NavigationStack`.
    ///
    /// This method should be used when building the column for a `NavigationSplitView`.
    /// - Parameter column: The column type.
    /// - Returns: A Destination, if one was found.
    func rootDestination(for column: NavigationSplitViewColumn) -> (any ViewDestinationable<PresentationConfiguration>)?
    
    
}


public extension NavigationSplitViewDestinationable {
    
    func presentDestination(destination: any ViewDestinationable<PresentationConfiguration>, in column: NavigationSplitViewColumn, shouldUpdateSelectedColumn: Bool = true, presentationOptions: NavigationStackPresentationOptions? = nil, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        DestinationsSupport.logger.log("Presenting View \(destination.type) in splitview column \(column).", level: .verbose)

        let currentColumnDestination = self.rootDestination(for: column)
        
        if shouldUpdateSelectedColumn {
            currentChildDestination = destination
        }
        
        // If the current Destination is a NavigationStack, add the presented Destination to it
        // Otherwise replace the current View with the new one
        if let navDestination = currentColumnDestination as? any NavigatingViewDestinationable<PresentationConfiguration> {
            addChild(childDestination: destination)
            let shouldAnimate = presentationOptions?.shouldAnimate ?? true
            navDestination.addChild(childDestination: destination, shouldAnimate: shouldAnimate)
            
        } else if let currentColumnDestination {
            replaceChild(currentID: currentColumnDestination.id, with: destination, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
        } else {
            addChild(childDestination: destination)
        }
                
        switch column {
            case .sidebar:
                currentSidebar = ContainerView(view: AnyView(self.destinationView(for: destination)))
            case .content:
                currentContent = ContainerView(view: AnyView(self.destinationView(for: destination)))
            case .detail:
                currentDetail = ContainerView(view: AnyView(self.destinationView(for: destination)))
            default:
                break
        }
        
        if let navDestination = destination as? any NavigatingViewDestinationable<PresentationConfiguration> {
            registerNavigationClosures(for: navDestination)
        }
        
    }
    
    func updateChildren() {
        updateColumnViews(columns: destinationIDsForColumns)
    }

    
    func replaceChild(currentID: UUID, with newDestination: any Destinationable<PresentationConfiguration>, removeDestinationFromFlowClosure: RemoveDestinationFromFlowClosure? = nil) {
        guard let newDestination = newDestination as? any ViewDestinationable<PresentationConfiguration> else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(newDestination.self)")
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
        }
        
        guard let currentIndex = childDestinations.firstIndex(where: { $0.id == currentID }), let currentDestination = childDestinations[safe: currentIndex] as? any ViewDestinationable, let currentColumn = column(destinationID: currentID) else {
            let template = DestinationsSupport.errorMessage(for: .childDestinationNotFound(message: ""))
            let message = String(format: template, self.type.rawValue)
            logError(error: DestinationsError.childDestinationNotFound(message: message))
            
            return
        }
        
        guard childDestinations.contains(where: { $0.id == newDestination.id}) == false else {
            DestinationsSupport.logger.log("Destination of type \(newDestination.type) was already in childDestinations, could not replace child \(currentID).", category: .error)
            return
        }

        DestinationsSupport.logger.log("Replacing NavigationSplitView destination with \(newDestination.type)", level: .verbose)
                
        childDestinations.insert(newDestination, at: currentIndex)
        newDestination.parentDestinationID = id
        destinationIDsForColumns[currentColumn] = newDestination.id

        removeChild(identifier: currentID, removeDestinationFromFlowClosure: removeDestinationFromFlowClosure)
        
        currentChildDestination = newDestination
        
        switch currentColumn {
            case .sidebar:
                currentSidebar = ContainerView(view: AnyView(self.destinationView(for: newDestination)))
            case .content:
                currentContent = ContainerView(view: AnyView(self.destinationView(for: newDestination)))
            case .detail:
                currentDetail = ContainerView(view: AnyView(self.destinationView(for: newDestination)))
            default:
                break
        }
        
        if let navDestination = newDestination as? any NavigatingViewDestinationable<PresentationConfiguration> {
            registerNavigationClosures(for: navDestination)
        }
        
        if let newDestination = newDestination as? any ViewDestinationable<PresentationConfiguration> {
            updateSplitView(destination: newDestination, for: currentColumn)
        }
        
    }
    
    func column(destinationID: UUID) -> NavigationSplitViewColumn? {
        return destinationIDsForColumns.first(where: { $0.value == destinationID })?.key
    }
    
    func rootDestination(for column: NavigationSplitViewColumn) -> (any ViewDestinationable<PresentationConfiguration>)? {
        guard let destinationID = destinationIDsForColumns[column] else { return nil }
        
        return childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<PresentationConfiguration>
    }
    
    func currentDestination(for column: NavigationSplitViewColumn) -> (any ViewDestinationable<PresentationConfiguration>)? {
        guard let destinationID = destinationIDsForColumns[column], let childDestination = childForIdentifier(destinationIdentifier: destinationID) as? any ViewDestinationable<PresentationConfiguration> else { return nil }

        // If the top-level Destination is a NavigationStack, we need to return Destination of the current path element in its navigationPath. Otherwise, return the top-level Destination itself
        if let navDestination = childDestination as? any NavigatingViewDestinationable<PresentationConfiguration>, let navigator = navDestination.navigator(), let lastID = navigator.currentPathElement(), let lastDestination = navDestination.childForIdentifier(destinationIdentifier: lastID) as? any ViewDestinationable<PresentationConfiguration> {

            return lastDestination

        } else {
            return childDestination
        }
        return nil
    }
    
    /// Updates multiple Destinations in the specified columns. This is used internally by Destinations.
    /// - Parameters:
    ///   - columns: An dictionary of Destination identifiers whose keys are column types.
    internal func updateColumnViews(columns: [NavigationSplitViewColumn: UUID]) {
        
        destinationIDsForColumns.removeAll()
        destinationIDsForColumns = columns
        
    }
    
    /// A `ViewBuilder` method that returns a strongly-typed `View` associated with the specified Destiantion.
    /// - Parameter destination: The Destination whose `View` should be returned.
    /// - Returns: A strongly-typed `View` associated with the specified Destination.
    @ViewBuilder internal func destinationView(for destination: any ViewDestinationable<PresentationConfiguration>) -> (some View)? {
        if let view = destination.currentView() {
            AnyView(view)
        }
    }
    
    /// Registers this object for feedback with an associated NavigatingViewDestinationable class. This is used internally by Destinations to make sure that this object updates properly when there are changes in the NavigationStack.
    /// - Parameter destination: A Destination with an associated NavigationStack.
    internal func registerNavigationClosures(for destination: any NavigatingViewDestinationable<PresentationConfiguration>) {
        DestinationsSupport.logger.log("Registering navigation closures for \(destination.description)", level: .verbose)

        destination.assignChildRemovedClosure { [weak self] destinationID in
            DestinationsSupport.logger.log("Child was removed closure", level: .verbose)

            self?.removeChild(identifier: destinationID)
        }

        destination.assignCurrentDestinationChangedClosure { [weak self, weak destination] destinationID in
            DestinationsSupport.logger.log("Current destination changed closure", level: .verbose)

            if let destinationID {
                self?.updateCurrentDestination(destinationID: destinationID)
            } else {
                self?.currentChildDestination = destination
            }
        }
        
    }
    
    /// Updates the identifier of the top-level Destination shown for the specified column. This is used internally by Destinations.
    /// - Parameters:
    ///   - destination: The Destination to update the column with.
    ///   - column: The type of column to update.
    internal func updateSplitView(destination: any ViewDestinationable<PresentationConfiguration>, for column: NavigationSplitViewColumn) {

        self.destinationIDsForColumns[column] = destination.id

        switch column {
            case .sidebar:
                currentSidebar = ContainerView(view: AnyView(self.destinationView(for: destination)))
            case .content:
                currentContent = ContainerView(view: AnyView(self.destinationView(for: destination)))
            case .detail:
                currentDetail = ContainerView(view: AnyView(self.destinationView(for: destination)))
            default:
                break
        }
    }
}


