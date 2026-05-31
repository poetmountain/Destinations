//
//  ColorDetailState.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class ColorDetailState: StateModeling {
    typealias Destination = ColorDetailDestination
    typealias EventType = Destination.Events
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

    func handleEvent(_ type: EventType, content: ContentType?) {
        switch type {
            case .goBack, .moveToNearest:
                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                })
        }
    }

    func prepareForAppearance(isVisible: Bool) {
        print("prepareForAppearance - \(String(describing: destination?.type)) : isVisible \(isVisible) : \(String(describing: destination?.id.uuidString))")
        didAppear = true
        didDisappear = false
        self.isVisible = isVisible
    }

    func prepareForDisappearance(wasVisible: Bool) {
        print("prepareForDisappearance - \(String(describing: destination?.type)) : wasVisible \(wasVisible) : \(String(describing: destination?.id.uuidString))")
        didAppear = false
        didDisappear = true
        isVisible = false
        self.wasVisible = wasVisible
    }
}
