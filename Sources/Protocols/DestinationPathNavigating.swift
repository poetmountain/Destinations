//
//  DestinationPathNavigating.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a Destination navigator path object. It should be implemented to allow for system-level navigation stacks like SwiftUI's `NavigationStack` into the Destinations ecosystem, which the ``DestinationNavigator`` class implements.
@MainActor public protocol DestinationPathNavigating: AnyObject {
    
    /// An array of `UUID` identifiers representing Destinations in the associated navigation path.
    var navigationPath: [UUID] { get set }

    /// The identifier of the current destination presentation.
    var currentPresentationID: UUID? { get set }
    
    /// The identifier of the Destination associated with this navigator.
    var navigatorDestinationID: UUID? { get set }
    
    /// Adds a Destination to the path.
    /// - Parameter item: A Destination identifier to be added to the path.
    /// - Parameter shouldAnimate: Determines whether this path element should be animated when presented.
    func addPathElement(item: UUID, shouldAnimate: Bool?)
    
    /// Returns the current path element. Typically this would be the identifier associated with a ``Destinationable`` object.
    /// - Returns: A `UUID` identifier of the associated element.
    func currentPathElement() -> UUID?
    
    /// Removes the current navigation element and makes the previous element in the path the current element.
    /// - Parameter previousPresentationID: An optional unique identifier of the previous destination.
    func backToPreviousPathElement(previousPresentationID: UUID?)
    
    /// Removes all previous elements, from the current navigation element until the element matching the specified identifier.
    /// - Parameter identifier: A `UUID` identifier that specifies which element should become the current identifer after removing elements ahead of it.
    /// - Returns: An array representing the remaining navigation elements of the path after removals.
    func backToElement(identifier: UUID) -> [UUID]
    
    /// Returns the previous path element.
    /// - Returns: A `UUID` identifier of the previous path element.
    func previousPathElement() -> UUID?
    
    /// Returns the index of the supplied element identifier, it is is present in the path.
    /// - Parameter element: The identifier
    /// - Returns: The position of the element, if it exists in the path.
    func index(of identifier: UUID) -> Int?
    
    /// Removes all path elements from the navigation path.
    func removeAll()
}

public extension DestinationPathNavigating {
    
    func addPathElement(item: UUID, shouldAnimate: Bool = true) {
        navigationPath.append(item)

    }
    
    func currentPathElement() -> UUID? {
        return navigationPath.last
    }
    
    func backToPreviousPathElement(previousPresentationID: UUID? = nil) {
        guard navigationPath.count > 0 else { return }
        currentPresentationID = previousPresentationID
        navigationPath.removeLast()
    }
    
    func backToElement(identifier: UUID) -> [UUID] {
        guard navigationPath.count > 0 else { return [] }
        currentPresentationID = identifier
        if let targetIndex = index(of: identifier) {
            let numToRemove = (navigationPath.count-1) - targetIndex
            let removedElements = navigationPath.suffix(numToRemove)
            navigationPath = Array(navigationPath[0...targetIndex])
            return Array(removedElements)
        }
        
        return []
    }
    
    func removeAll() {
        navigationPath.removeAll()
        currentPresentationID = nil
    }
    
    func previousPathElement() -> UUID? {
        let previousIndex = (navigationPath.count - 1) - 1

        if previousIndex >= 0 {
            return navigationPath[previousIndex]
        }
        return nil
    }
    
    func index(of identifier: UUID) -> Int? {
        return navigationPath.firstIndex(of: identifier)
    }
}
