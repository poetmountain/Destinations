//
//  AppDestinationTypes.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

protocol AppDestinationTypes {

    typealias EventType = GeneralAppEvents
    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias PresentationType = DestinationPresentationType<DestinationType, AppContentType, TabType>
    typealias ContentType = AppContentType
    
}

public enum AppTabType: TabTypeable {
    public var tabName: String {
        return ""
    }

}
