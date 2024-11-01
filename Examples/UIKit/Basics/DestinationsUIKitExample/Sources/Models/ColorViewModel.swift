//
//  ColorDetailViewModel.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 4/17/24.
//

import UIKit
import Destinations

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
