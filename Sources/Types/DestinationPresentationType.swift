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
public enum DestinationPresentationType<PresentationConfiguration: DestinationPresentationConfiguring>: DestinationPresentationTypeable, Equatable {
    
    /// An enum which defines types of tabs in a tab bar.
    public typealias TabType = PresentationConfiguration.TabType

    /// Represents a presentation action of a navigation stack such as a `UINavigationController` or SwiftUI's `NavigationStack`.
    ///
    /// - Parameter type: An enum representing the type of navigation action to be taken.
    case navigationController(type: NavigationPresentationType)
    
    /// Presents the specified tab of a tab bar such as a `UITabBarController` or SwiftUI's `TabView`.
    ///
    /// If a `destinationType` is specified along with this presentation type, the specified Destination will be presented in that tab, with the tab becoming active. However if no `destinationType` is present in the ``DestinationPresentation`` model, the specified tab will simply be selected, becoming the active tab within the interface.
    ///
    /// - Parameter type: An enum representing the tab that the Destination should be presented in.
    case tabBar(tab: TabType)
    
    /// Adds a Destination as a child of the currently presented Destination. Note that this type only works with UIKit and utilizes `UIViewController`'s `addChild` method.
    case addToCurrent
    
    /// Replaces the currently presented Destination with a new Destination in system UI components which allow that.
    case replaceCurrent
    
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
    case destinationPath(path: [PresentationConfiguration])
    
    /// Defines a custom presentation of a Destination. This presentation type can be used to support the presentation of non-standard interfaces or system components which Destinations does not directly support.
    ///
    /// - Parameter presentation: An object containing a closure which drives the custom presentation.
    /// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
    case custom(presentation: CustomPresentation<PresentationConfiguration>)
    
    public var rawValue: String {
        switch self {
            case .navigationController(let type):
                return "navigationController_\(type)"
            case .tabBar(let tab):
                return "tabBar_\(tab.tabName)"
            case .addToCurrent:
                return "addToCurrent"
            case .replaceCurrent:
                return "replaceCurrent"
            case .sheet(let type):
                return "sheet_\(type)"
            case .destinationPath(path: let path):
                return "destinationPath \(path.compactMap { $0.destinationType })"
            case .custom:
                return "custom"
        }
    }
    
    public static func == (lhs: DestinationPresentationType<PresentationConfiguration>, rhs: DestinationPresentationType<PresentationConfiguration>) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
