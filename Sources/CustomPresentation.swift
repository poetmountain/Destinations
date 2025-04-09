//
//  CustomPresentation.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A closure which drives a custom SwiftUI Destination presentation.
///
/// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
public typealias CustomViewPresentationClosure<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable> = (
    _ destinationToPresent: (any ViewDestinationable<DestinationType, ContentType, TabType>)?,
    _ currentDestination: (any ViewDestinationable<DestinationType, ContentType, TabType>)?,
    _ parentOfCurrentDestination: (any ViewDestinationable)?,
    _ completionClosure: ((Bool) -> Void)?) -> Void


/// A closure which drives a custom UIKit Destination presentation.
///
/// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
public typealias CustomControllerPresentationClosure<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable> = (
    _ destinationToPresent: (any ControllerDestinationable<DestinationType, ContentType, TabType>)?,
    _ rootController: (any ControllerDestinationInterfacing)?,
    _ currentDestination: (any ControllerDestinationable)?,
    _ parentOfCurrentDestination: (any ControllerDestinationable)?,
    _ completionClosure: ((Bool) -> Void)?) -> Void

/// This model provides closures which drive a custom Destination presentation.
public struct CustomPresentation<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable> {
    
    /// A closure which drives a custom UIKit Destination presentation.
    ///
    /// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
    public var uiKit: CustomControllerPresentationClosure<DestinationType, ContentType, TabType>?
    
    /// A closure which drives a custom SwiftUI Destination presentation.
    ///
    /// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
    public var swiftUI: CustomViewPresentationClosure<DestinationType, ContentType, TabType>?
    
    /// The initializer.
    /// - Parameters:
    ///   - uiKit: A closure which drives a custom UIKit Destination presentation.
    ///   - swiftUI: A closure which drives a custom SwiftUI Destination presentation.
    public init(uiKit: CustomControllerPresentationClosure<DestinationType, ContentType, TabType>? = nil, swiftUI: CustomViewPresentationClosure<DestinationType, ContentType, TabType>? = nil) {
        self.uiKit = uiKit
        self.swiftUI = swiftUI
    }
}
