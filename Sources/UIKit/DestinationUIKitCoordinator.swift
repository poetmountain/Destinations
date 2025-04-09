//
//  DestinationUIKitCoordinator.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// This class coordinates the presentation of a Destination within the UIKit framework.
@MainActor public final class DestinationUIKitCoordinator: NSObject, DestinationUIKitCoordinating {
    
    /// A reference to the root `ControllerDestinationInterfacing` object in a UIKit app.
    public var rootController: (any ControllerDestinationInterfacing)?
    
    /// A closure which is called when a Destination should be removed from the ecosystem, typically after it's associated UI object is no longer being presented.
    public var removeDestinationClosure: RemoveDestinationFromFlowClosure?
        
    /// The Destination that currently should be presented.
    public var destinationToPresent: (any Destinationable)?

    /// A delegate protocol object which can subscribe to this object to receive updates about the status of destination presentations.
    public weak var delegate: DestinationInterfaceCoordinatorDelegate?
    
    /// The initializer.
    /// - Parameter rootController: A reference to the root `ControllerDestinationInterfacing` object in a UIKit app.
    public init(rootController: (any ControllerDestinationInterfacing)? = nil) {
        super.init()

        self.rootController = rootController
        
        if let navController = rootController as? UINavigationController {
            navController.delegate = self
        }
        
    }
    
    
    /// Handles the presentation of a Destination's associated `UIViewController` in a UIKit app.
    /// - Parameters:
    ///   - destination: The Destination to present.
    ///   - currentDestination: The currently presented Destination.
    ///   - parentOfCurrentDestination: The parent of the current Destination.
    ///   - configuration: The configuration object for this presentation.
    public func presentControllerDestination<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable>(
        destination: (any ControllerDestinationable<DestinationType, ContentType, TabType>)? = nil,
        currentDestination: (any ControllerDestinationable)?,
        parentOfCurrentDestination: (any ControllerDestinationable)?,
        tabBarDestinationInViewHiearchy: (any TabBarControllerDestinationable)?,
        configuration: DestinationPresentation<DestinationType, ContentType, TabType>) {
        
        let newController = destination?.currentController()
        
        destinationToPresent = destination
            
        configuration.handlePresentation(destinationToPresent: destination, rootController: rootController, currentDestination: currentDestination, parentOfCurrentDestination: parentOfCurrentDestination, removeDestinationClosure: removeDestinationClosure)
        
        if let navController = newController?.navigationController {
            navController.delegate = self
        } else if let navController = rootController as? UINavigationController {
            navController.delegate = self
        } else if let navController = newController as? UINavigationController, navController.delegate == nil {
            navController.delegate = self
        }
        
        if let tabBarDestinationInViewHiearchy {
            tabBarDestinationInViewHiearchy.registerNavigationControllerDelegates(with: self)
        }
        
    }

    
    /// Handles movement along the navigation stack.
    func handleMovement(from fromVC: UIViewController, to toVC: UIViewController) {
        guard let navController = fromVC.navigationController ?? rootController as? UINavigationController, fromVC != toVC else { return }
        
        let fromIndex = navController.viewControllers.firstIndex { $0 == fromVC }
        let toIndex = navController.viewControllers.firstIndex { $0 == toVC }
        DestinationsSupport.logger.log("👋 handle movement from \(fromVC.self) - index \(fromIndex) to \(toVC.self) - index \(toIndex)", level: .verbose)

        var isDescending = false
        if let fromIndex = fromIndex, let toIndex = toIndex {
            isDescending = (toIndex >= fromIndex)
        }
        

        // Notify Flow object that the popped destination should be removed
        let isOldVCPopped = (navController.viewControllers.contains(fromVC) == false) || (navController.viewControllers.count == 1)
        if isOldVCPopped {
            if let destinationVC = fromVC as? any DestinationInterfacing, isDescending == false {
                let destination = destinationVC.destination()
                removeDestinationClosure?(destination.id)

            }
        }

        // make controller being presented the current destination
        if let presentedVC = toVC as? (any DestinationInterfacing), isDescending == false {
            let destination = presentedVC.destination()
            delegate?.didRequestCurrentDestinationChange(newDestinationID: destination.id)
        }
    }
    
    
    // MARK: - UINavigationControllerDelegate methods
    
    /// UINavigationControllerDelegate delegate method
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        handleMovement(from: fromVC, to: toVC)

        return nil
    }
    
    /// UINavigationControllerDelegate delegate method
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let vcCount = navigationController.viewControllers.count
        guard (vcCount >= 2), animated == false else { return }
        let previousVC = navigationController.viewControllers[vcCount-2]
        
        handleMovement(from: previousVC, to: viewController)
    }
}
