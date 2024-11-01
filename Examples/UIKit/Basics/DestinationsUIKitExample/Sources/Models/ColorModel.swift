//
//  ColorModel.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 4/17/24.
//

import UIKit

struct ColorModel: Hashable {
    let colorID: UUID = UUID()
    let color: UIColor
    let name: String?
}
