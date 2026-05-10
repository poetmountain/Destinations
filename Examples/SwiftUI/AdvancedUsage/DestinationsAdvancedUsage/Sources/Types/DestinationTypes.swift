//
//  DestinationTypes.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

protocol DestinationTypes {

    typealias InteractorType = AppInteractorType
    typealias DestinationType = Route
    typealias TabType = AppTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias ContentType = AppContentType
    
}

