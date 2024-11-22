//
//  ContainerView.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// Provides a wrapper for a SwiftUI `View`, useful for passing `View`s in models.
@MainActor public struct ContainerView<Content: View>: View, Identifiable, Equatable {

    /// A unique identifier.
    public var id = UUID()
    
    /// The SwiftUI `View` to contain.
    @ViewBuilder public let content: Content
    
    /// An initializer that takes a closure that contains a `View`.
    /// - Parameter content: The SwiftUI `View` to contain.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    /// An initializer that takes a `View` directly.
    /// - Parameter view: The `View` to contain.
    public init(view: Content) {
        self.content = view
    }
    
    public var body: some View {
        content
    }
    
    nonisolated public static func == (lhs: ContainerView<Content>, rhs: ContainerView<Content>) -> Bool {
        lhs.id == rhs.id
    }
}


