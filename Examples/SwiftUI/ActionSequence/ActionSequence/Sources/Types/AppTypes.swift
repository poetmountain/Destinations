//
//  AppTypes.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

/// The Destinations which can be routed to in this app.
enum RouteDestinationType: String, RoutableDestinations {

    var id: String { rawValue }

    case sequenceDemo
}

/// The types of tabs in this app. This app doesn't use a tab bar, but a tab type is required by Destinations' generics.
enum AppTabType: String, TabTypeable {

    case demo

    var tabName: String {
        switch self {
            case .demo:
                return "Demo"
        }
    }

    var imageName: String {
        switch self {
            case .demo:
                return "photo"
        }
    }
}

/// The types of Interactors used in this app. Each step of the demo's ActionSequence targets one of these Interactors.
enum AppInteractorType: InteractorTypeable {
    case imageRetrieval
    case imageSaver
    case imageFilter
}

/// Errors which can occur while running the demo's ActionSequence.
enum SequenceDemoError: LocalizedError {
    
    case invalidImageURL
    
    /// The downloaded data could not be decoded into an image.
    case imageDecodingFailed

    /// The save step received no image file content to save.
    case missingImageFile
    
    /// Transforming the image to the data model failed.
    case invalidImage

    var errorDescription: String? {
        switch self {
            case .invalidImageURL:
                return "The URL for downloading an image is invalid."
            case .imageDecodingFailed:
                return "The downloaded data could not be decoded into an image."
            case .missingImageFile:
                return "No image file content was provided to the save step."
            case .invalidImage:
                return "The image is invalid and could not be transformed to a data model."
        }
    }
}

protocol DestinationTypes {

    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias ContentType = AppContentType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>

}
