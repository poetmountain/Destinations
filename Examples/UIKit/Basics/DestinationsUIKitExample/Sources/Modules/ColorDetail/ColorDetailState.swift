//
//  ColorDetailState.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class ColorDetailState: StateModeling {
    typealias Destination = ColorDetailViewController.Destination
    typealias EventType = ColorDetailViewController.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var colorModel: ColorViewModel?

    init(colorModel: ColorViewModel? = nil) {
        self.colorModel = colorModel
    }

    func handleEvent(_ type: EventType, content: ContentType?) {
        switch type {
            case .colorDetailButton, .customDetailButton:
                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                })
        }
    }

    func prepareForAppearance(isVisible: Bool) {
        if isVisible {
            print("prepareForAppearance - \(String(describing: destination?.type)) : is visible \(isVisible) : \(String(describing: destination?.id.uuidString))")
        }
    }

    func prepareForDisappearance(wasVisible: Bool) {
        if wasVisible {
            print("prepareForDisappearance - \(String(describing: destination?.type)) : was visible \(wasVisible) : \(String(describing: destination?.id.uuidString))")
        }
    }
}
