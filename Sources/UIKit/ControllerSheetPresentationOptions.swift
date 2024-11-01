//
//  ControllerSheetPresentationOptions.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A closure used for configuring a `UISheetPresentationController` before the sheet is presented.
public typealias SheetPresentationControllerConfigurationClosure = (_ presentationController: UISheetPresentationController) -> Void

/// A model providing configuration options for UIKit sheet presentations.
public struct ControllerSheetPresentationOptions {
    
    /// Used to set the `UIModalPresentationStyle` of a presented controller.
    public var presentationStyle: UIModalPresentationStyle?
    
    /// Used to set the `UIModalTransitionStyle` of a presented controller.
    public var transitionStyle: UIModalTransitionStyle?
    
    /// Provides a `UIViewControllerTransitioningDelegate` object to be used for custom presentation transitions.
    ///
    /// - Note: This holds a weak reference to the delegate object, so you should save a reference to this object until the transition is complete.
    public weak var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    /// Used to determine whether the sheet controller should be animated when being presented.
    public var isAnimated: Bool = true
    
    /// A closure used for configuring a `UISheetPresentationController` before the sheet is presented.
    public var configurationClosure: SheetPresentationControllerConfigurationClosure?
    
    /// The initializer.
    /// - Parameters:
    ///   - presentationStyle: Sets the `UIModalPresentationStyle` of a presented controller.
    ///   - transitionStyle: Sets the `UIModalTransitionStyle` of a presented controller.
    ///   - transitionDelegate: Provides a `UIViewControllerTransitioningDelegate` object to be used for custom presentation transitions.
    ///   - isAnimated: Determines whether the sheet controller should be animated when being presented.
    ///   - configurationClosure: A closure used for configuring a `UISheetPresentationController` before the sheet is presented.
    public init(presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, transitionDelegate: UIViewControllerTransitioningDelegate? = nil, isAnimated: Bool? = nil, configurationClosure: SheetPresentationControllerConfigurationClosure? = nil) {
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
        self.transitionDelegate = transitionDelegate
        if let isAnimated {
            self.isAnimated = isAnimated
        }
        self.configurationClosure = configurationClosure
    }
}
