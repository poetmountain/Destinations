//
//  SwiftUIAdapter.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import SwiftUI

 /// Adapts a SwiftUI `View` for use inside a `UIViewController`, using a `UIHostingController` to present it within UIKit.
@MainActor public final class SwiftUIAdapter<Content: ViewDestinationInterfacing>: SwiftUIAdaptable {
    
    /// A SwiftUI `View` to display.
    public var view: Content

    /// A reference to the parent of the hosting controller.
    weak public var parentController: UIViewController? = nil {
        didSet {
            setupUI()
        }
    }
    
    /// The hosting controller for the SwiftUI `View`.
    public var hostingController: UIHostingController<Content>
    
    /// The initializer.
    /// - Parameters:
    ///   - content: The SwiftUI `View` to adapt.
    ///   - parent: A reference to the parent of the hosting controller.
    public init(@ViewBuilder content: () -> Content, parent: UIViewController? = nil) {
        self.view = content()
        hostingController = UIHostingController(rootView: view)
        self.parentController = parent

    }
    
    private func setupUI() {
        if let parent = parentController {
            parent.attach(viewController: hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor)
            ])
        }
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        hostingController.removeFromParent()
        hostingController.didMove(toParent: nil)
    }

}

