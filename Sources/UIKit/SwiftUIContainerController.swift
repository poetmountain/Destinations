//
//  SwiftUIContainerController.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

/// A controller that serves as a container for a SwiftUI `View`.
public final class SwiftUIContainerController<Content: SwiftUIHostedInterfacing>: UIViewController, SwiftUIContainerInterfacing {
    
    public typealias InteractorType = Content.InteractorType
    public typealias UserInteractionType = Content.UserInteractionType
    public typealias PresentationConfiguration = Content.PresentationConfiguration
    public typealias DestinationType = PresentationConfiguration.DestinationType
    public typealias Destination = SwiftUIContainerDestination<Content, PresentationConfiguration>

    
    /// The Destination associated with the contained SwiftUI `View`.
    public var destinationState: SwiftUIHostingState<Content, PresentationConfiguration> {
        get {
            return adapter.view.hostingState
        }
        
        set {
            
        }
    }
    

    /// The SwiftUI `View` contained by this controller.
    public var swiftUIView: Content {
        return adapter.view
    }
    
    /// The adapter which holds the associated SwiftUI `View` and presents it in a `UIHostingController`.
    public var adapter: SwiftUIAdapter<Content>
    
    /// The initializer.
    /// - Parameter adapter: The adapter which holds the associated SwiftUI `View` and presents it in a `UIHostingController`.
    public init(adapter: SwiftUIAdapter<Content>) {
        self.adapter = adapter
        
        super.init(nibName: nil, bundle: nil)
        
        self.adapter.parentController = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func cleanupResources() {
        adapter.cleanupResources()
    }
}
