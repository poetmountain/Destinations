//
//  Extensions.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

extension UIViewController {
    
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

extension Array {
    mutating func popFirst() -> Element? {
        if self.count > 0 {
            return self.removeFirst()
        } else {
            return nil
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension UINavigationController {
    func replaceLastController(with newController: UIViewController) {
        if viewControllers.count > 1 {
            popViewController(animated: false)
            pushViewController(newController, animated: false)
            popToViewController(newController, animated: false)
        } else {
            setViewControllers([newController], animated: false)
        }
    }
    
    func previousController() -> UIViewController? {
        if viewControllers.count > 1 {
            let currentIndex = viewControllers.count - 1
            let previousIndex = currentIndex - 1
            if (previousIndex >= 0) {
                return viewControllers[previousIndex]
            }
        }
        return nil
    }
}
