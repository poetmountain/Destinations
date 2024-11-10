//
//  ColorDetailViewModel.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Combine
import Destinations

@Observable
public final class ColorViewModel: Hashable, Identifiable, Sendable {
    
    public let id: UUID
    let color: UIColor
    let name: String?
    
    init(colorID: UUID? = nil, color: UIColor, name: String? = nil) {
        self.id = colorID ?? UUID()
        self.color = color
        self.name = name
    }
    
    // Hashable custom value implementation
    // to be useful and performant in Set operations we only want to compare the UUID
    // in Set operations I don't care about whether name or color or relationship refs have changed
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
