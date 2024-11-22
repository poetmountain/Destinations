//
//  NavigationSplitViewDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A Destination which represents a SwiftUI `View` that contains a `NavigationSplitView`.
///
/// This is a generic Destination that can be used to represent `NavigationSplitView` implementations in a SwiftUI-based app.
///
/// To implement the `NavigationSplitView` associated with this Destination and to enable dynamic updating of your `NavigationSplitView`'s column, bind these properties from inside each column's closure using a ``BindableContainerView``.
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
@Observable public final class NavigationSplitViewDestination<PresentationConfigurationType: DestinationPresentationConfiguring, SplitViewType: NavigationSplitViewDestinationInterfacing>: NavigationSplitViewDestinationable where PresentationConfigurationType.DestinationType == SplitViewType.DestinationType {
    
    /// An enum which defines all routable Destinations in the app.
    public typealias DestinationType = SplitViewType.DestinationType
    
    /// An enum which defines types of tabs in a tab bar.
    public typealias TabType = PresentationConfigurationType.TabType
    
    /// An enum which defines the types of content that are able to be sent through Destinations.
    public typealias ContentType = PresentationConfigurationType.ContentType
    
    /// An enum which defines types of Interactors. Each Destination may have its own Interactor types.
    public typealias InteractorType = SplitViewType.InteractorType
    
    /// A model type which configures Destination presentations. Typically this is a ``DestinationPresentation``.
    public typealias PresentationConfiguration = PresentationConfigurationType
    
    /// An enum which defines user interaction types for this Destination's interface.
    public typealias UserInteractionType = SplitViewType.UserInteractionType
    
    /// The type of `View` associated with this Destination.
    public typealias ViewType = SplitViewType
    
    public let id = UUID()
    
    public let type: DestinationType
    
    public var view: ViewType?

    public var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    public var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    public var destinationIDsForColumns: [NavigationSplitViewColumn: UUID] = [:]
    
    public var currentSidebar: ContainerView<AnyView> = ContainerView(view: AnyView(EmptyView()))
    public var currentContent: ContainerView<AnyView> = ContainerView(view: AnyView(EmptyView()))
    public var currentDetail: ContainerView<AnyView> = ContainerView(view: AnyView(EmptyView()))
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    public var interactors: [InteractorType : any Interactable] = [:]
    public var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    public var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    public var interactorAssistants: [UserInteractionType: any InteractorAssisting<NavigationSplitViewDestination>] = [:]

    
    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?

    public var supportsIgnoringCurrentDestinationStatus: Bool = true

    public var listID: UUID = UUID()

    public var isSystemNavigating: Bool = false
    
    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationsForColumns: A dictionary of `View`-based Destination objects, whose associated keys are the `NavigationSplitViewColumn` column type should be displayed in.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationsForColumns: [NavigationSplitViewColumn: any ViewDestinationable<PresentationConfiguration>], destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil) {
        self.type = destinationType
        self.parentDestinationID = parentDestinationID
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
        
        for (column, destination) in destinationsForColumns {
            destinationIDsForColumns[column] = destination.id
            presentDestination(destination: destination, in: column)
        }
    }
}
