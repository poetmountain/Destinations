//
//  DestinationPresentationConfiguring.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents a configuration object for the presentation of a Destination. Classes adopting this protocol should handle the presentation of Destinations within the system UI framework being used.
@MainActor public protocol DestinationPresentationConfiguring<DestinationType, TabType, ContentType>: AnyObject {
    
    /// An enum which defines all routable Destinations in the app.
    associatedtype DestinationType: RoutableDestinations
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    associatedtype ContentType: ContentTypeable
    
    /// An enum which defines types of tabs in a tab bar.
    associatedtype TabType: TabTypeable
    
    /// A ``DestinationPresentationType`` configured for this configuration object.
    typealias PresentationType = DestinationPresentationType<Self>

    /// A unique identifier.
    var id: UUID { get }

    /// An enum representing the type of Destination to be presented.
    var destinationType: DestinationType? { get set }
        
    /// An enum type representing the way this Destination should be presented.
    var presentationType: PresentationType { get }
    
    /// The unique identifier of the currently presented Destination.
    var currentDestinationID: UUID? { get set }
    
    /// The unique identifier of the parent of the Destination to be presented.
    var parentDestinationID: UUID? { get set }
    
    /// An enum type representing the content to be used with this presentation.
    var contentType: ContentType? { get set }
    
    /// An enum representing the type of action used with this presentation.
    var actionType: DestinationActionType { get }
    
    /// The unique identifier of the target of this presentation, if one exists.
    var actionTargetID: UUID? { get set }
    
    /// The type of `InterfaceAction` assistant to be used to configure this presentation.
    var assistantType: ActionAssistantType { get set }
    
#if canImport(SwiftUI)
    /// The ``DestinationPathNavigating`` object associated with the Destination to be presented.
    var navigator: (any DestinationPathNavigating)? { get set }
#endif
    
#if canImport(SwiftUI)
    /// A reference to a ``TabBarViewDestinationable`` object, should one currently exist in the UI hierarchy.
    var tabBarDestination: (any TabBarViewDestinationable<Self, TabType>)? { get set }
#endif

#if canImport(UIKit)
    /// A reference to a ``TabBarControllerDestinationable`` object, should one currently exist in the UI hierarchy.
    var tabBarControllerDestination: (any TabBarControllerDestinationable<Self, TabType>)? { get set }
#endif
    
    /// A Boolean which determines whether the activation of the presentation's completion closure, referenced in the ``completionClosure`` property, should be delayed.
    var shouldDelayCompletionActivation: Bool { get set }
    
    /// A Boolean which determines whether the Destination configured by this presentation should become the current one within the `Flowable` and `GroupedDestinationable` objects which manage it.
    ///
    /// The Destinations protocols and classes which handle UINavigationControllers/NavigationStacks and UITabController/TabBars ignore this property. Custom classes which conform to one of these protocols should handle this property appropriately, though generally speaking if a Destination is added to a `GroupedDestinationable` object, it would be a good user experience for that Destination to become the focus. This may vary based on how your custom group's children are displayed to the user.
    ///
    /// - Important: Setting this property to `false` can have side effects on the presentation of future Destinations within `GroupedDestinationable` objects whose placement depends on the location of a previous Destination. For example, if you present a Destination in a non-active child of a  `GroupedDestinationable` object with this property set to `false`, then present another Destination with a `presentationType` of `navigationController`, depending on how you handle this property the Destination may not be put into the same child of the group because the active child will be different than if this property had been `true`. To overcome this, you would need to use a `presentationType` on the second presentation that targets the same child directly.
    var shouldSetDestinationAsCurrent: Bool { get set }
        
    /// A completion closure which should be run upon completion of the presentation of the Destination.
    var completionClosure: ((_ didComplete: Bool) -> Void)? { get set }

#if canImport(UIKit)
    /// Handles the presentation of a UIKit-based Destination.
    /// - Parameters:
    ///   - destinationToPresent: The ``ControllerDestinationable`` Destination to present.
    ///   - rootController: A ``ControllerDestinationInterfacing`` object representing the root of the UI hierarchy.
    ///   - currentDestination: A ``ControllerDestinationable`` object, representing the currently presented Destination.
    ///   - parentOfCurrentDestination: A ``ControllerDestinationable`` object, representing the parent of the current Destination.
    ///   - removeDestinationClosure: An optional closure to the run when the Destination is removed from the UI hierarchy.
    func handlePresentation(destinationToPresent: (any ControllerDestinationable<Self>)?, rootController: (any ControllerDestinationInterfacing)?, currentDestination: (any ControllerDestinationable)?, parentOfCurrentDestination: (any ControllerDestinationable)?, removeDestinationClosure: RemoveDestinationClosure?)
#endif
    
#if canImport(SwiftUI)
    /// Handles the presentation of a SwiftUI-based Destination.
    /// - Parameters:
    ///   - destinationToPresent: The ``ViewDestinationable`` Destination to present.
    ///   - rootController: A `UIViewController` representing the root of the UI hierarchy.
    ///   - currentDestination: A ``ViewDestinationable`` object, representing the currently presented Destination.
    ///   - parentOfCurrentDestination: A ``ViewDestinationable`` object, representing the parent of the current Destination.
    ///   - removeDestinationClosure: An optional closure to the run when the Destination is removed from the UI hierarchy.
    func handlePresentation(destinationToPresent: (any ViewDestinationable<Self>)?, currentDestination: (any ViewDestinationable<Self>)?, parentOfCurrentDestination: (any ViewDestinationable)?, removeDestinationClosure: RemoveDestinationClosure?)
#endif
    
    /// Creates a copy of this object.
    /// - Returns: A copy of this object.
    func copy() -> Self
}
