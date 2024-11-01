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
public typealias CustomViewPresentationClosure<DestinationPresentation: DestinationPresentationConfiguring> = (
    _ destinationToPresent: (any ViewDestinationable<DestinationPresentation>)?,
    _ currentDestination: (any ViewDestinationable<DestinationPresentation>)?,
    _ parentOfCurrentDestination: (any ViewDestinationable)?,
    _ completionClosure: ((Bool) -> Void)?) -> Void


/// A closure which drives a custom UIKit Destination presentation.
///
/// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
public typealias CustomControllerPresentationClosure<DestinationPresentation: DestinationPresentationConfiguring> = (
    _ destinationToPresent: (any ControllerDestinationable<DestinationPresentation>)?,
    _ rootController: (any ControllerDestinationInterfacing)?,
    _ currentDestination: (any ControllerDestinationable)?,
    _ parentOfCurrentDestination: (any ControllerDestinationable)?,
    _ completionClosure: ((Bool) -> Void)?) -> Void

/// This model provides closures which drive a custom Destination presentation.
public struct CustomPresentation<PresentationConfiguration: DestinationPresentationConfiguring> {
    
    /// A closure which drives a custom UIKit Destination presentation.
    ///
    /// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
    public var uiKit: CustomControllerPresentationClosure<PresentationConfiguration>?
    
    /// A closure which drives a custom SwiftUI Destination presentation.
    ///
    /// - Important: At the end of your custom presentation you must call `completionClosure`, passing a Boolean for whether the presentation or setup succeeds or fails.
    public var swiftUI: CustomViewPresentationClosure<PresentationConfiguration>?
    
    /// The initializer.
    /// - Parameters:
    ///   - uiKit: A closure which drives a custom UIKit Destination presentation.
    ///   - swiftUI: A closure which drives a custom SwiftUI Destination presentation.
    public init(uiKit: CustomControllerPresentationClosure<PresentationConfiguration>? = nil, swiftUI: CustomViewPresentationClosure<PresentationConfiguration>? = nil) {
        self.uiKit = uiKit
        self.swiftUI = swiftUI
    }
}
