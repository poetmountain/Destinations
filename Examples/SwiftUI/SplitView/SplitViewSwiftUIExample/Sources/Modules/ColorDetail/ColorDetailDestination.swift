//
//  ColorDetailDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct CollectionDatasourceOptions {
    let numItemsToDisplay: Int?
}

@Observable
final class ColorDetailDestination: ViewDestinationable, AppDestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable, Equatable {
        
        var rawValue: String {
            ""
        }

    }
    
    enum InteractorType: InteractorTypeable {
        case colors
    }

    
    typealias ViewType = ColorDetailView
    typealias UserInteractionType = UserInteractions


    public let id = UUID()
    
    public let type: RouteDestinationType = .colorDetail
    
    public var view: ViewType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    

    var items: [ColorViewModel] = []

    private(set) var listID: UUID = UUID()

    public var isSystemNavigating: Bool = false

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    func prepareForPresentation() {
    }

}
