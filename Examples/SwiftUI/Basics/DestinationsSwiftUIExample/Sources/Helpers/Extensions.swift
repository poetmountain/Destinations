//
//  Extensions.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

public extension Array {

    subscript(safe idx: Int) -> Element? {
        guard idx >= 0, idx < count else { return nil }
        return self[idx]
    }
    
    /// Always returns an array, if range its out of bounds it will change it to self's startIndes or endIndex
    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        return self[Swift.min(Swift.max(0, range.startIndex), endIndex)..<Swift.min(range.endIndex, endIndex)]
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

typealias VoidClosure = () -> Void
