//
//  ColorModel.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

struct ColorModel: Hashable {
    let colorID: UUID = UUID()
    let color: UIColor
    let name: String?
}
