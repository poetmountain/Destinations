//
//  ColorDetailState.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class ColorDetailState: StateModeling {
    typealias Destination = ColorDetailView.Destination
    typealias EventType = ColorDetailView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var colorModel: ColorViewModel?

    init(colorModel: ColorViewModel? = nil) {
        self.colorModel = colorModel
    }

    func handleEvent(_ type: EventType, content: ContentType?) {

    }

    func prepareForAppearance(isVisible: Bool) {
        DestinationsSupport.logger.log("prepareForAppearance - \(String(describing: destination?.type)) : is visible: \(isVisible)")
    }

    func prepareForDisappearance(wasVisible: Bool) {
        DestinationsSupport.logger.log("prepareForDisappearance - \(String(describing: destination?.type)) : was visible: \(wasVisible)")
    }
}
