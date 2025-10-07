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
    
    public var glassBackgroundVisibility: Visibility = .automatic
    
    /// The initializer.
    /// - Parameters:
    ///   - buttonImage: The button image to show for the back button.
    ///   - useGlassBackground: Determines whether the Liquid Glass background should be shown in iOS 26. The default visibility is `automatic`.
    ///   - selectionAction: An optional action to perform when the button is tapped.
    public init(buttonImage: Image? = nil, useGlassBackground: Bool? = nil, selectionAction: (() -> Void)? = nil) {
        if let buttonImage {
            self.buttonImage = buttonImage
        }
        if let useGlassBackground {
            self.glassBackgroundVisibility = useGlassBackground ? .visible : .hidden
        }
        
        self.selectionAction = selectionAction
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {

                if #available(iOS 26.0, *) {
#if swift(>=6.2)
                    buildBackButton()
                        .sharedBackgroundVisibility(glassBackgroundVisibility)
#else
                    buildBackButton()
#endif
                } else {
                    buildBackButton()
                }
                    
            }
            
    }
    
    func buildBackButton() -> some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                selectGoBack()
            } label: {
                buttonImage
            }
        }
        
    }
    
    func selectGoBack() {
        selectionAction?()
    }
}


public extension View {

    /// Adds a replacement button for `View`s being presented in a `NavigationStack`.
    /// - Parameters:
    ///   - buttonImage: The button image to show for the back button.
    ///   - useGlassBackground: Determines whether the Liquid Glass background should be shown in iOS 26. The default visibility is `automatic`.
    ///   - selectionAction: An optional action to perform when the back button is tapped.
    /// - Returns: The `View` which provides the navigation bar customization.
    public func goBackButton(buttonImage: Image? = nil, useGlassBackground: Bool? = nil, selectionAction: (() -> Void)?) -> some View {
        modifier(BackNavigationModifier(buttonImage: buttonImage, useGlassBackground: useGlassBackground, selectionAction: selectionAction))
    }

}

public extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}

public extension ToolbarItemGroup {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}
