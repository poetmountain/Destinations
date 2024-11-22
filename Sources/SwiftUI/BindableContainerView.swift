//
//  BindableContainerView.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

/// This `View` provides a way to display a `View` that is fed from an external binding.
@MainActor public struct BindableContainerView: View, Identifiable {

    /// A unique identifier.
    public var id = UUID()
    
    /// The SwiftUI `View` to contain.
    public var content: Binding<ContainerView<AnyView>>
    
    /// An initializer.
    /// - Parameter content: A bindable container for a `View` to be displayed in this `View`.
    public init(content: Binding<ContainerView<AnyView>>) {
        self.content = content
    }
    
    public var body: some View {
        content.wrappedValue
        .id(content.wrappedValue.id)
    }
    
    nonisolated public static func == (lhs: BindableContainerView, rhs: BindableContainerView) -> Bool {
        lhs.id == rhs.id
    }
}
