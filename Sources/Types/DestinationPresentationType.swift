//
//  DestinationPresentationType.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// An enum representing the supported presentation types in Destinations.
public enum DestinationPresentationType<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable>: DestinationPresentationTypeable, Equatable {
        
    /// Represents a presentation action of a navigation stack such as a `UINavigationController` or SwiftUI's `NavigationStack`.
    ///
    /// - Parameter type: An enum representing the type of navigation action to be taken.
    case navigationStack(type: NavigationPresentationType)
        
    /// Presents a Destination in the specified tab of a tab bar such as a `UITabBarController` or SwiftUI's `TabView`.
    ///
    /// If a `destinationType` is specified along with this presentation type, the specified Destination will be presented in that tab, with the tab becoming active. However if no `destinationType` is present in the ``DestinationPresentation`` model, the specified tab will simply be selected, becoming the active tab within the interface.
    ///
    /// - Parameter tab: An enum representing the tab that the Destination should be presented in.
    case tabBar(tab: TabType)
    
    /// Presents a Destination in a column of a split view interface, such as a `UISplitViewController` or SwiftUI's `NavigationSplitView`.
    ///
    /// - Parameter column: A model representing a particular column in the split view interface.
    ///
    /// Please choose the appropriate framework property for the interface you're using (`UISplitViewController` or `NavigationSplitView`). Not providing the expected property will result in an error when the presenting a Destination with this presentation type.
    case splitView(column: SplitViewColumn)
    
    /// Adds a Destination as a child of the currently presented Destination. Note that this type only works with UIKit and utilizes `UIViewController`'s `addChild` method.
    case addToCurrent
    
    /// Replaces the currently presented Destination with a new Destination in system UI components which allow that.
    case replaceCurrent
    
    /// Removes all active Destinations in the Flow and sets a new root Destination.
    case replaceRoot
    
    /// Defines the presentation of a sheet view.
    ///
    /// - Parameter type: An enum representing the state of the sheet.
    /// - Parameter options: A model that provides options for configuring how the sheet is presented.
    case sheet(type: SheetPresentationType, options: SheetPresentationOptions? = nil)
    
    /// Presents a path of multiple Destinations, useful for navigating to a nested interface view.
    ///
    /// - Parameter path: An array of presentation configuration models representing the Destinations to be presented.
    ///
    /// > Note: The array order of the configuration objects is the order in which the Destinations will be presented.
    case destinationPath(path: [DestinationPresentation<DestinationType, ContentType, TabType>])
    
    /// Defines a custom presentation of a Destination. This presentation type can be used to support the presentation of non-standard interfaces or system components which Destinations does not directly support.
    ///
    /// - Parameter presentation: An object containing a closure which drives the custom presentation.
    /// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
    case custom(presentation: CustomPresentation<DestinationType, ContentType, TabType>)
    
    nonisolated public var rawValue: String {
        switch self {
            case .navigationStack(let type):
                return "navigationStack"
            case .splitView:
                return "splitView"
            case .tabBar(let tab):
                return "tabBar"
            case .addToCurrent:
                return "addToCurrent"
            case .replaceCurrent:
                return "replaceCurrent"
            case .replaceRoot:
                return "replaceRoot"
            case .sheet(let type):
                return "sheet"
            case .destinationPath(path: let path):
                return "destinationPath"
            case .custom:
                return "custom"
        }
    }
    
    nonisolated public static func == (lhs: DestinationPresentationType<DestinationType, ContentType, TabType>, rhs: DestinationPresentationType<DestinationType, ContentType, TabType>) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
