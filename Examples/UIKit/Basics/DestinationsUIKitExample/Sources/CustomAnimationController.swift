//
//  CustomAnimationController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

final class CustomAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private var presentedConstraints: [NSLayoutConstraint] = []
    private var startingConstraints: [NSLayoutConstraint] = []

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        present(using: transitionContext)
     }

    private func present(using context: UIViewControllerContextTransitioning) {
        guard let presentedView = context.view(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        context.containerView.addSubview(presentedView)
        presentedView.translatesAutoresizingMaskIntoConstraints = false

        presentedConstraints = [
            presentedView.leftAnchor.constraint(equalTo: context.containerView.leftAnchor),
            presentedView.rightAnchor.constraint(equalTo: context.containerView.rightAnchor),
            presentedView.topAnchor.constraint(equalTo: context.containerView.topAnchor),
            presentedView.bottomAnchor.constraint(equalTo: context.containerView.bottomAnchor)
        ]

        startingConstraints = [
            presentedView.leftAnchor.constraint(equalTo: context.containerView.leftAnchor),
            presentedView.rightAnchor.constraint(equalTo: context.containerView.rightAnchor),
            presentedView.topAnchor.constraint(equalTo: context.containerView.centerYAnchor)
        ]

        NSLayoutConstraint.activate(startingConstraints)

        context.containerView.setNeedsLayout()
        context.containerView.layoutIfNeeded()

        NSLayoutConstraint.deactivate(startingConstraints)
        NSLayoutConstraint.activate(presentedConstraints)

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.2,
            options: .curveEaseInOut,
            animations: {
                context.containerView.setNeedsLayout()
                context.containerView.layoutIfNeeded()
            },
            completion: { _ in
                context.completeTransition(true)
            })
    }
    

}

final class AnimationTransitionCoordinator: NSObject, UIViewControllerTransitioningDelegate {
    
    let animator = CustomAnimationController()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return animator
    }
    
}
