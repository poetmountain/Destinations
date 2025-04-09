//
//  TabViewDestination.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A Destination which represents a SwiftUI `View` which contains a `TabView`.
///
/// This is a generic Destination that can be used to represent most `TabView`s in a SwiftUI-based app.
@Observable
public final class TabViewDestination<ViewType: TabBarViewDestinationInterfacing, UserInteractionType: UserInteractionTypeable, DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable, InteractorType: InteractorTypeable>: TabBarViewDestinationable {
    
    public let id = UUID()
    
    public var type: DestinationType
    
    public var view: ViewType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()
    

    public var destinationIDsForTabs: [TabType: UUID] = [:]
    public var activeTabs: [TabModel<TabType>] = []
    
    public var selectedTab: TabModel<TabType> {
        didSet {
            selectedTabUpdatedClosure?(selectedTab)
        }
    }
    
    public var destinationPresentationClosure: TabBarViewDestinationPresentationClosure<DestinationType, ContentType, TabType>?
    
    public var selectedTabUpdatedClosure: TabBarViewSelectedTabUpdatedClosure<TabType>?

    
    /// The initializer.
    /// - Parameters:
    ///   - type: The type of Destination.
    ///   - tabDestinations: An array of Destinations for each tab, in order of appearance.
    ///   - tabTypes: An array of tab types, in order of appearance.
    ///   - selectedTab: The type of tab that should be initially selected.
    ///   - destinationConfigurations: The Destination presentation configurations associated with this Destination.
    ///   - navigationConfigurations: The system navigation events associated with this Destination.
    ///   - parentDestinationID: The identifier of the parent Destination.
    public init?(type: DestinationType, tabDestinations: [any ViewDestinationable<DestinationType, ContentType, TabType>], tabTypes: [TabType], selectedTab: TabType, destinationConfigurations: AppDestinationConfigurations<UserInteractionType, DestinationType, ContentType, TabType>? = nil, navigationConfigurations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>? = nil, parentDestinationID: UUID? = nil) {
        self.type = type

        var tabModels: [TabModel<TabType>] = []
        var selectedModel: TabModel<TabType>?
        var selectedIndex: Int?
        
        for tabDestination in tabDestinations {
            tabDestination.setParentID(id: id)
        }
        
        for (index, type) in tabTypes.enumerated() {
            let model = TabModel(type: type)
            tabModels.append(model)
            if type == selectedTab {
                selectedModel = model
                selectedIndex = index
            }
        }
        
        if let selectedModel {
            self.selectedTab = selectedModel
        } else {
            DestinationsSupport.logger.log("The specified selectedTab type was not found in the supplied tabs array. Initialization of TabViewDestination failed.", category: .error)
            return nil
        }
        
        if let selectedIndex {
            groupInternalState.currentChildDestination = tabDestinations[selectedIndex]
        }
        
        internalState.destinationConfigurations = destinationConfigurations
        internalState.systemNavigationConfigurations = navigationConfigurations
        internalState.parentDestinationID = parentDestinationID

        
        updateTabViews(destinationIDs: tabDestinations.map { $0.id }, for: tabModels)

        for (index, tab) in tabTypes.enumerated() {
            if let destination = tabDestinations[safe: index] {
                do {
                    try presentDestination(destination: destination, in: tab, shouldUpdateSelectedTab: false)
                } catch {
                    DestinationsSupport.logger.log("Error presenting tab Destination \(error)", category: .error)
                }
            }
        }
        
    }
    
    public func prepareForPresentation() {
    }
    
}

extension TabViewDestination: @preconcurrency CustomStringConvertible {
    public var description: String {
        return "\(Self.self) : \(type) : \(id)"
    }
}
