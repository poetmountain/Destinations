//
//  Extensions.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

extension Array {
    
    subscript(safe idx: Int) -> Element? {
        guard idx >= 0, idx < count else { return nil }
        return self[idx]
    }
    
    /// Always returns an array, if range its out of bounds it will change it to self's startIndes or endIndex
    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        return self[Swift.min(Swift.max(0, range.startIndex), endIndex)..<Swift.min(range.endIndex, endIndex)]
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIViewController {
    
    /// The `addChildViewController` method has some issues, this takes care of them. Call the `detach` method to remove it from the view hierarchy.
    public func attach(viewController: UIViewController) {
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    public func detach(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
    }
}

extension UITabBarItem {
    func tabBarItemShowingOnlyImage() -> UITabBarItem {
        // offset to center
        self.imageInsets = UIEdgeInsets(top: 12, left:0, bottom:-20, right:0)
        // displace to hide
        self.titlePositionAdjustment = UIOffset(horizontal:0, vertical:-30000)
        
        return self
    }

    func tabBarItemShowingOnlyText() -> UITabBarItem {
        self.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16)
        return self
    }
}

typealias VoidClosure = () -> Void
