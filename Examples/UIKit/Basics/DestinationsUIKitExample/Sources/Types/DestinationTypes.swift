//
//  DestinationTypes.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 6/22/24.
//

import Foundation
import Destinations

protocol DestinationTypes {

    typealias UserInteractionType = GeneralAppInteractions
    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias PresentationType = DestinationPresentationType<DestinationPresentation<DestinationType, AppContentType, TabType>>
    typealias ContentType = AppContentType
    
}

