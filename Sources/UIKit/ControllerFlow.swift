//
//  ControllerFlow.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A concrete Flow class designed to be used to manage Destinations flows within the UIKit framework. In most cases creating a custom Flow object is unnecessary, and this class can be used as-is in your UIKit-based app.
public final class ControllerFlow<DestinationType: RoutableDestinations, TabType: TabTypeable, ContentType: ContentTypeable>: NSObject, ControllerFlowable, UITabBarControllerDelegate {
    
    public typealias DestinationType = DestinationType
    public typealias TabType = TabType
    public typealias ContentType = ContentType
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>
    public typealias InterfaceCoordinator = DestinationUIKitCoordinator
    
    public var activeDestinations: [any Destinationable<DestinationPresentation<DestinationType, ContentType, TabType>>] = []
    
    public var currentDestination: (any Destinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)?
        
    public var destinationProviders: [DestinationType: any ControllerDestinationProviding] = [:]
            
    public var uiCoordinator: DestinationUIKitCoordinator? = DestinationUIKitCoordinator()
            
    public var rootDestination: (any Destinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)?

    public var destinationQueue: [DestinationPresentation<DestinationType, ContentType, TabType>] = []
    
    /// The starting Destination in the Flow.
    public var startingDestination: DestinationPresentation<DestinationType, ContentType, TabType>?
        
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationProviders: A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    ///   - startingDestination: The starting Destination.
    public init(destinationProviders: [DestinationType: any ControllerDestinationProviding], startingDestination: DestinationPresentation<DestinationType, ContentType, TabType>) {
        self.destinationProviders = destinationProviders
        self.startingDestination = startingDestination
        
        super.init()
        
        self.uiCoordinator?.removeDestinationClosure = { [weak self]  (_ removalID: UUID) in
            guard let strongSelf = self else { return }
            strongSelf.removeDestination(destinationID: removalID)
        }
        self.uiCoordinator?.delegate = self
    }

    public func start()  {
        if let startingDestination {
            let loggingStartingAction: String = startingDestination.destinationType != nil ? startingDestination.destinationType.debugDescription : "\(startingDestination.presentationType.rawValue)"
            DestinationsSupport.logger.log("🏁 Starting Destinations flow with \(loggingStartingAction).")
            
            if case DestinationPresentationType.destinationPath(path: let path) = startingDestination.presentationType {
                self.presentDestinationPath(path: path)
            } else {
                rootDestination = presentDestination(configuration: startingDestination)
            }
            
        }
    }
    
    public func assignRoot(rootController: any ControllerDestinationInterfacing) {
        uiCoordinator?.rootController = rootController
    }
    
    public func destination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)? {
        var existingDestination: (any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)?
        let existingID: UUID? = configuration.actionTargetID
        
        if let existingID {
            if configuration.actionType == .presentation, let activeDestination = activeDestinations.first(where: { $0.parentDestinationID == existingID }) as? any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>> {
                existingDestination = activeDestination
                
            } else if configuration.actionType == .systemNavigation, let activeDestination = activeDestinations.first(where: { $0.id == existingID }) as? any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>>  {
                existingDestination = activeDestination
            }

        }
        
        if let destinationToReturn = existingDestination ?? buildDestination(for: configuration) {
            return destinationToReturn
        } else {
            return nil
        }

    }
    
    @discardableResult public func presentDestination(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)? {
        
        if case DestinationPresentationType.destinationPath(path: let path) = configuration.presentationType {
            self.presentDestinationPath(path: path, contentToPass: configuration.contentType)
            return nil
        }
        
        var mutableConfiguration = configuration
        var parentOfCurrentDestination: (any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)?
        
        if let parentID = currentDestination?.parentDestinationID, let parent = self.destination(for: parentID) as? any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>> {
            parentOfCurrentDestination = parent
        }
        
        let destination = self.destination(for: mutableConfiguration)
                
        var currentDestination = currentDestination as? any ControllerDestinationable<DestinationPresentation<DestinationType, ContentType, TabType>>
        
        if case .splitView(column: let column) = configuration.presentationType, let current = currentDestination {
            guard column.uiKit != nil else {
                let template = DestinationsSupport.errorMessage(for: .undefinedSplitViewColumnType(message: ""))
                let message = String(format: template, "uiKit")
                DestinationsSupport.logError(error: DestinationsError.undefinedSplitViewColumnType(message: message))
                
                return nil
            }
            
            currentDestination = findSplitViewInViewHierarchy(currentDestination: current)
        }

        var tabDestination: (any TabBarControllerDestinationable<PresentationConfiguration, TabType>)?
        if let currentDestination = currentDestination ?? rootDestination as? any ControllerDestinationable {
            tabDestination = findTabBarInViewHierarchy(currentDestination: currentDestination)
        }
        
        if var destination {

            if let tabController = destination.currentController() as? UITabBarController {
                tabController.delegate = self
            }
                        
            if let current = currentDestination, let tabDestination {
                mutableConfiguration.tabBarControllerDestination = tabDestination
            }
            
            mutableConfiguration.completionClosure = self.presentationCompletionClosure(for: mutableConfiguration, destination: destination)
            
            uiCoordinator?.presentControllerDestination(destination: destination, currentDestination: currentDestination, parentOfCurrentDestination: parentOfCurrentDestination, tabBarDestinationInViewHiearchy: tabDestination, configuration: mutableConfiguration)
            
            return destination
            
        } else {
            
            if let current = currentDestination, let tabDestination {
                mutableConfiguration.tabBarControllerDestination = tabDestination
            }
            
            mutableConfiguration.completionClosure = self.presentationCompletionClosure(for: mutableConfiguration, destination: nil)
            
           uiCoordinator?.presentControllerDestination(destination: destination, currentDestination: currentDestination, parentOfCurrentDestination: parentOfCurrentDestination, tabBarDestinationInViewHiearchy: tabDestination, configuration: mutableConfiguration)
            
        }

        return nil
        
    }
    
    
    public func presentationCompletionClosure(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>, destination: (any Destinationable<DestinationPresentation<DestinationType, ContentType, TabType>>)? = nil) -> PresentationCompletionClosure? {
        var closure: PresentationCompletionClosure?
        
        switch configuration.presentationType {
            case .navigationController(type: .goBack):
                closure = self.defaultNavigationBackCompletionClosure(configuration: configuration)

            case .sheet(type: .dismiss, options: _):
                closure = self.defaultSheetDismissalCompletionClosure(configuration: configuration)
                
            default:
                closure = self.defaultCompletionClosure(configuration: configuration, destination: destination)
                
        }
        
        return closure
    }
    
    
    // MARK: UITabBarControllerDelegate methods
    
    /// UITabBarControllerDelegate delegate method
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        if let navController = tabBarController.selectedViewController as? UINavigationController, let controllerToPresent = navController.visibleViewController as? any DestinationInterfacing, let destination = self.destination(for: controllerToPresent.destination().id) {
            
            if let tabBarDestinationController = tabBarController as? any TabBarControllerDestinationInterfacing {
                tabBarDestinationController.destination().updateCurrentDestination(destinationID: controllerToPresent.destination().id)
            }
            
            self.updateCurrentDestination(destination: destination)
            
        }
        
    }
    
}

extension ControllerFlow: DestinationInterfaceCoordinatorDelegate {
    public func didRequestCurrentDestinationChange(newDestinationID: UUID) {
        if let presentedDestination = self.destination(for: newDestinationID), presentedDestination.id != currentDestination?.id {
            updateCurrentDestination(destination: presentedDestination)
        }
    }
}

