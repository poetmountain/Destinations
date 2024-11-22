//
//  AppDestinationTypes.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

protocol AppDestinationTypes {

    typealias UserInteractionType = GeneralAppInteractions
    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationPresentation<DestinationType, AppContentType, TabType>>
    typealias ContentType = AppContentType
    
}

public enum AppTabType: TabTypeable {
    public var tabName: String {
        return ""
    }

}

enum GeneralAppInteractions: UserInteractionTypeable {
    var rawValue: String {
        return ""
    }
}

public enum AppInteractorType: InteractorTypeable {
    case test
}
