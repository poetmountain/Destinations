//
//  ColorsListRow.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct ColorsListRow: View {
    
    var item: ColorViewModel
    
    init(item: ColorViewModel) {
        self.item = item
    }
    var body: some View {
        if let name = item.name {
            Text(name)
        }
    }
}

