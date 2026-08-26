//
//  DataModel.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A model representing a Data object which should be written to disk, along with the file name to save it under.
struct DataModel: Sendable, Equatable {
    let data: Data
    let fileName: String

    init(data: Data, fileName: String) {
        self.data = data
        self.fileName = fileName
    }
}
