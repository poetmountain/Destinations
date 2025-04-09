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
@Observable public final class NavigationSplitViewDestination<ViewType: NavigationSplitViewDestinationInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: NavigationSplitViewDestinationable {
   
    public let id = UUID()
    
    public let type: DestinationType
    
    public var view: ViewType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

    public var destinationIDsForColumns: [NavigationSplitViewColumn: UUID] = [:]
    
    public var currentSidebar: ContainerView<AnyView> = ContainerView(view: AnyView(EmptyView()))
    public var currentContent: ContainerView<AnyView> = ContainerView(view: AnyView(EmptyView()))
    public var currentDetail: ContainerView<AnyView> = ContainerView(view: AnyView(EmptyView()))
    
    public var listID: UUID = UUID()

    
    /// The initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination.
    ///   - destinationsForColumns: A dictionary of `View`-based Destination objects, whose associated keys are the `NavigationSplitViewColumn` column type should be displayed in.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init(destinationType: DestinationType, destinationsForColumns: [NavigationSplitViewColumn: any ViewDestinationable<DestinationType, ContentType, TabType>], destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestinationID: UUID? = nil) {
        self.type = destinationType
        self.internalState.parentDestinationID = parentDestinationID
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
        
        for (column, destination) in destinationsForColumns {
            destinationIDsForColumns[column] = destination.id
            presentDestination(destination: destination, in: column)
        }
    }
    
    public func prepareForPresentation() {
    }
}
