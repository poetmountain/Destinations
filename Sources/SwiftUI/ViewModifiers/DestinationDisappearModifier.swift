//
//  DestinationDisappearModifier.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A `ViewModifier` that handles the removal of a Destination from the Destinations ecosystem when its associated `View` disappears from a `NavigationStack`.
public struct DestinationDisappearModifier: ViewModifier {
    
    /// The Destination that is disappearing.
    public weak var destination: (any ViewDestinationable)?
    
    /// The Destination whose `View` contains a `NavigationStack`.
    public weak var navigationDestination: (any NavigatingViewDestinationable)?
    
    /// The presentation identifier of the system action moving back in the `NavigationStack`.
    public var presentationID: UUID?
    
    /// An optional action to perform when the button is tapped.
    public var disappearanceAction: (() -> Void)?
    
    /// The initializer.
    /// - Parameters:
    ///   - destination: The Destination that is disappearing.
    ///   - navigationDestination: The Destination whose `View` contains a `NavigationStack`.
    ///   - action: An optional action to perform when the button is tapped.
    public init(destination: any ViewDestinationable, navigationDestination: any NavigatingViewDestinationable, action: (() -> Void)? = nil) {
        self.destination = destination
        self.navigationDestination = navigationDestination
        self.presentationID = destination.systemNavigationPresentation(for: .navigateBackInStack)?.id
        self.disappearanceAction = action
    }
    
    public func body(content: Content) -> some View {
        content
            .onDisappear {
                DestinationsOptions.logger.log("Destination is disappearing \(destination?.description) :: isSystemNavigating? \(destination?.isSystemNavigating)", level: .verbose)

                guard let destination, let presentationID, destination.isSystemNavigating == true else { return }
                
                disappearanceAction?()

                navigationDestination?.removeChild(identifier: destination.id)
                
                if let presentation = destination.systemNavigationPresentation(presentationID: presentationID), presentation.shouldDelayCompletionActivation {
                    
                    presentation.completionClosure?(true)
                    
                }
                
            }
    }

}

public extension View {
    
    /// Handles the removal of a Destination from the Destinations ecosystem when its associated `View` disappears.
    /// - Parameters:
    ///   - destination: A `Destination` whose disappearance should be tracked.
    ///   - navigationDestination: A Destination whose `View` contains a `NavigationStack`.
    ///   - action: An optional action to perform when the `View` disappears.
    /// - Returns: A `View` which runs the removal logic and optional action when it disappears.
    public func onDestinationDisappear(destination: any ViewDestinationable, navigationDestination: any NavigatingViewDestinationable, action: (() -> Void)? = nil) -> some View {
        modifier(DestinationDisappearModifier(destination: destination, navigationDestination: navigationDestination, action: action))
    }
}
