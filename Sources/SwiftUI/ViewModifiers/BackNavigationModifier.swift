//
//  BackNavigationModifier.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// A `ViewModifier` that adds a custom back button for `NavigationStack` views, which allows integration with ``NavigatingViewDestinationable``-conforming Views.
public struct BackNavigationModifier: ViewModifier {
    
    /// The button image to show for the back button.
    public var buttonImage: Image = Image(systemName: "arrow.left")
    
    /// An optional action to perform when the button is tapped.
    public var selectionAction: (() -> Void)?
    
    /// The initializer.
    /// - Parameters:
    ///   - buttonImage: The button image to show for the back button.
    ///   - selectionAction: An optional action to perform when the button is tapped.
    public init(buttonImage: Image? = nil, selectionAction: (() -> Void)? = nil) {
        if let buttonImage {
            self.buttonImage = buttonImage
        }
        self.selectionAction = selectionAction
    }
    
    public func body(content: Content) -> some View {
        content
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : { [self] in
            selectGoBack()
        }){
            buttonImage
        })
    }
    
    func selectGoBack() {
        selectionAction?()
    }
}


public extension View {

    /// Adds a replacement button for `View`s being presented in a `NavigationStack`.
    /// - Parameters:
    ///   - buttonImage: The button image to show for the back button.
    ///   - selectionAction: An optional action to perform when the back button is tapped.
    /// - Returns: The `View` which provides the navigation bar customization.
    public func goBackButton(buttonImage: Image? = nil, selectionAction: (() -> Void)?) -> some View {
        modifier(BackNavigationModifier(buttonImage: buttonImage, selectionAction: selectionAction))
    }

}
