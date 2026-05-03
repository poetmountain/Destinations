//
//  ColorDetailDestination.swift
//  SplitViewUIKitExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorDetailSwiftUIDestination: ViewDestinationable, DestinationTypes {
    @AutoCaseIterable
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            ""
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationType, AppContentType, TabType>
    
    typealias ViewType = ColorDetailView

    public let id = UUID()
    
    public let type: RouteDestinationType = .colorDetailSwiftUI
    
    public var view: ViewType?
    
    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }

    func prepareForPresentation() {
    }
}
