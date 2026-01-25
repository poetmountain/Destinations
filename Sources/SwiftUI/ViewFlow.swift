//
//  ViewFlow.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A concrete Flow class designed to be used to manage Destinations flows within the SwiftUI framework. In most cases creating a custom Flow object is unnecessary, and this class can be used as-is in your SwiftUI-based app.
public final class ViewFlow<DestinationType: RoutableDestinations, TabType: TabTypeable, ContentType: ContentTypeable>: ViewFlowable, ObservableObject {
        
    /// A type of object that coordinates the presentation of a Destination within a UI framework.
    public typealias InterfaceCoordinator = DestinationSwiftUICoordinator

    public var activeDestinations: [any Destinationable<DestinationType, ContentType, TabType>] = []
    
    public var currentDestination: (any Destinationable<DestinationType, ContentType, TabType>)?
        
    public var destinationProviders: [DestinationType: any ViewDestinationProviding] = [:]
            
    public var uiCoordinator: DestinationSwiftUICoordinator?
            
    @Published public var rootDestination: (any Destinationable<DestinationType, ContentType, TabType>)?

    public var destinationQueue: [DestinationPresentation<DestinationType, ContentType, TabType>] = []
    
    /// The starting Destination in the Flow.
    public var startingDestination: DestinationPresentation<DestinationType, ContentType, TabType>?
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationProviders: A dictionary of Destination providers whose keys are an enum of Destination types. The Destination type represents the type of Destination each provider can provide.
    ///   - startingDestination: The starting Destination.
    public init(destinationProviders: [DestinationType: any ViewDestinationProviding], startingDestination: DestinationPresentation<DestinationType, ContentType, TabType>) {
        self.destinationProviders = destinationProviders
        self.startingDestination = startingDestination
        self.uiCoordinator = DestinationSwiftUICoordinator()

        self.uiCoordinator?.removeDestinationClosure = { [weak self]  (_ uuid: UUID) in
            guard let strongSelf = self else { return }
            
            if let destinationToRemove = strongSelf.destination(for: uuid) as? any ViewDestinationable, let parentID = destinationToRemove.parentDestinationID(), let parentDestination = strongSelf.destination(for: parentID), let navigationStackDestination = parentDestination as? NavigatingViewDestinationable {
                navigationStackDestination.currentView()?.backToPreviousDestination(currentDestination: destinationToRemove)
            } else {
                strongSelf.removeDestination(destinationID: uuid)
            }
        }
        self.uiCoordinator?.delegate = self
    }

    public func start()  {
        if let startingDestination {
            let loggingStartingAction: String = startingDestination.destinationType != nil ? startingDestination.destinationType.debugDescription : "\(startingDestination.presentationType.rawValue)"
            DestinationsSupport.logger.log("🏁 Starting Destinations flow with \(loggingStartingAction).")
            
            if let newDestination = presentDestination(configuration: startingDestination) {
                rootDestination = newDestination
            }
        
        }
    }

    /// Return an existing destination or build a new one
    public func destination(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>) -> (any ViewDestinationable<DestinationType, ContentType, TabType>)? {
        
        var existingDestination: (any ViewDestinationable<DestinationType, ContentType, TabType>)?
        let existingID: UUID? = configuration.actionTargetID
        
        if let existingID {
            if configuration.actionType == .presentation, let activeDestination = activeDestinations.first(where: { $0.parentDestinationID() == existingID && $0.type == configuration.destinationType }) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                existingDestination = activeDestination
                
            } else if case .sheet(type: .dismiss, options: _) = configuration.presentationType,  let activeDestination = activeDestinations.first(where: { $0.parentDestinationID() == existingID || $0.id == existingID }) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                existingDestination = activeDestination

            } else if configuration.actionType == .systemNavigation, let activeDestination = activeDestinations.first(where: { $0.id == existingID }) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
                existingDestination = activeDestination
            }

        }
        
        if let destinationToReturn = existingDestination ?? buildDestination(for: configuration) {
            return destinationToReturn
        } else {
            return nil
        }
    }
    
    
    
    @discardableResult public func presentDestination(configuration: DestinationPresentation<DestinationType, ContentType, TabType>) ->  (any ViewDestinationable<DestinationType, ContentType, TabType>)? {

        if case DestinationPresentationType.destinationPath(path: let path) = configuration.presentationType {
            DestinationsSupport.logger.log("⤴️ Presenting destination destinationPath: \(path.compactMap { $0.destinationType })")
            self.presentDestinationPath(path: path, contentToPass: configuration.contentType)
            return nil
        } else {
            let destinationType = configuration.destinationType?.rawValue ?? "none"
            DestinationsSupport.logger.log("⤴️ Presenting destination \(destinationType) via \(configuration.presentationType)")
        }

        var mutableConfiguration = configuration
        var parentOfCurrentDestination: (any ViewDestinationable)?
        
        if let parentID = currentDestination?.parentDestinationID(), let parent = self.destination(for: parentID) as? any ViewDestinationable<DestinationType, ContentType, TabType> {
            parentOfCurrentDestination = parent
        }
        
        if case .moveToNearest(destination: let destinationToVisit) = configuration.presentationType {
            removeDestinationsBefore(nearest: destinationToVisit)            
        }
        
        var newDestination = self.destination(for: mutableConfiguration)

        var currentViewDestination = currentDestination as? any ViewDestinationable<DestinationType, ContentType, TabType>
        
        if case .splitView(column: let column) = configuration.presentationType, let current = currentViewDestination {
            guard column.swiftUI != nil else {
                let template = DestinationsSupport.errorMessage(for: .undefinedSplitViewColumnType(message: ""))
                let message = String(format: template, "uiKit")
                DestinationsSupport.logError(error: DestinationsError.undefinedSplitViewColumnType(message: message))
                
                return nil
            }
            
            currentViewDestination = findSplitViewInViewHierarchy(currentDestination: current)
        }
        
        
        if var newDestination = newDestination {
            
            if let parentID = currentViewDestination?.parentDestinationID() ?? mutableConfiguration.parentDestinationID, let parent = self.destination(for: parentID) as? any ViewDestinationable {
                parentOfCurrentDestination = parent
            }
            
            if let current = currentViewDestination, let tabDestination = findTabBarInViewHierarchy(searchDestination: current) {
                mutableConfiguration.tabBarDestination = tabDestination
            }
            
            if rootDestination == nil {
                rootDestination = newDestination
            }
            
            if case DestinationPresentationType.navigationStack(type: .present) = mutableConfiguration.presentationType {
                if let currentViewDestination, let navigator = findNavigatorInViewHierarchy(searchDestination: currentViewDestination), let navID = navigator.navigatorDestinationID, let navDestination = self.destination(for: navID) as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType> {
                    parentOfCurrentDestination = navDestination
                    // assign the navigator presenting this Destination
                    newDestination.setPresentingNavigator(navigator: navigator)
                }
            }
            
            if case DestinationPresentationType.tabBar(tab: let tab) = mutableConfiguration.presentationType {
                if let currentViewDestination, let navigator = findNavigatorInViewHierarchy(searchDestination: currentViewDestination), let navID = navigator.navigatorDestinationID, let navDestination = self.destination(for: navID) as? any NavigatingViewDestinationable<DestinationType, ContentType, TabType> {
                    parentOfCurrentDestination = navDestination
                    // assign the navigator presenting this Destination
                    newDestination.setPresentingNavigator(navigator: navigator)
                }
            }
            
            // Called every time a Destination is newly presented (hence not when going back in a navigation stack)
            if case DestinationPresentationType.navigationStack(type: let navigationType) = mutableConfiguration.presentationType {
                if navigationType == .present {
                    newDestination.prepareForPresentation()
                }
            } else {
                newDestination.prepareForPresentation()
            }
      
            mutableConfiguration.completionClosure = self.presentationCompletionClosure(for: mutableConfiguration, destination: newDestination)

            updateDestination(destination: newDestination)
            
            // handle use case where the top-level Destination should be replaced
            if configuration.presentationType == .replaceRoot || (configuration.presentationType == .replaceCurrent && activeDestinations.count == 1) {
                
                replaceRootDestination(with: newDestination)
            }
        

            uiCoordinator?.presentViewDestination(destination: newDestination, currentDestination: currentViewDestination, parentOfCurrentDestination: parentOfCurrentDestination, configuration: mutableConfiguration)
            
            return newDestination
            
        } else {
            
            if let current = currentViewDestination, let tabDestination = findTabBarInViewHierarchy(searchDestination: current) {
                mutableConfiguration.tabBarDestination = tabDestination
            }
            
            mutableConfiguration.completionClosure = self.presentationCompletionClosure(for: mutableConfiguration, destination: newDestination)

            uiCoordinator?.presentViewDestination(destination: nil, currentDestination: currentViewDestination, parentOfCurrentDestination: parentOfCurrentDestination, configuration: mutableConfiguration)
            
            
        }
        
        return nil
    
    }
    
    
    public func presentationCompletionClosure(for configuration: DestinationPresentation<DestinationType, ContentType, TabType>, destination: (any Destinationable<DestinationType, ContentType, TabType>)? = nil) -> PresentationCompletionClosure? {
        var closure: PresentationCompletionClosure?
        
        switch configuration.presentationType {
            case .navigationStack(type: .goBack), .moveToNearest(destination: _):
                closure = self.defaultNavigationBackCompletionClosure(configuration: configuration)

            case .sheet(type: .dismiss, options: _):
                closure = self.defaultSheetDismissalCompletionClosure(configuration: configuration)
                
            default:
                closure = self.defaultCompletionClosure(configuration: configuration, destination: destination)
                
        }
        
        return closure
    }
    

}

extension ViewFlow: DestinationInterfaceCoordinatorDelegate {
    public func didRequestCurrentDestinationChange(newDestinationID: UUID) {

        if let presentedDestination = self.destination(for: newDestinationID), presentedDestination.id != currentDestination?.id {
            updateCurrentDestination(destination: presentedDestination)
        }
    }
}
