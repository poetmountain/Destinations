//
//  ColorViewModel.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

public struct ColorViewModel: Sendable, Hashable, Identifiable {
    
    public var id: UUID = UUID()
    let color: UIColor
    let name: String?
    
    init(colorID: UUID? = nil, color: UIColor, name: String? = nil) {
        if let colorID {
            self.id = colorID
        }
        self.color = color
        self.name = name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ColorViewModel: Equatable {
    public static func == (lhs: ColorViewModel, rhs: ColorViewModel) -> Bool {
        return (lhs.id == rhs.id) && (lhs.color == rhs.color) && (lhs.name == rhs.name)
    }
    
    
}

extension ColorViewModel: CustomStringConvertible {
    public var description : String {
        return "name: \(String(describing: name)) (\(self.id)"
    }
}
