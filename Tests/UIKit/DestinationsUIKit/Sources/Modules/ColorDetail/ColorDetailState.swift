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

    weak var destination: Destination?

    var colorModel: ColorViewModel?

    var didAppear: Bool = false
    var didDisappear: Bool = false

    var isVisible: Bool = false
    var wasVisible: Bool = false

    init(colorModel: ColorViewModel? = nil) {
        self.colorModel = colorModel
    }

    func handleEvent(_ type: EventType, content: ContentType? = nil) {
        switch type {
            case .colorDetailButton, .moveToNearest:
                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                })
        }
    }

    func prepareForAppearance(isVisible: Bool) {
        didAppear = true
        didDisappear = false
        self.isVisible = isVisible
    }

    func prepareForDisappearance(wasVisible: Bool) {
        didAppear = false
        didDisappear = true
        isVisible = false
        self.wasVisible = wasVisible
    }
}
