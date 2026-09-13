//
//  ColorDetailState.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@Observable
final class ColorDetailState: StateModeling, SheetPresenting {
    typealias Destination = ColorDetailView.Destination
    typealias EventType = ColorDetailView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var colorModel: ColorViewModel?
    var sheetView: ContainerView<AnyView>?

    var sheetPresentation = SheetPresentation()
    
    init(colorModel: ColorViewModel? = nil) {
        self.colorModel = colorModel
    }

    func handleEvent(_ type: EventType, content: ContentType? = nil) {
        switch type {
            case .colorDetailButton:
                showSheet(for: type)

        }
    }
    
    private func showSheet(for type: EventType) {
        buildSheet()
        guard let sheetView else { return }

        destination?.handleThrowable(closure: { [weak destination] in
            try destination?.performAction(for: type, content: .dynamicView(view: sheetView))
        })
    }
    
    private func buildSheet() {
        sheetView = ContainerView {
            AnyView(
                ColorSheetView(colorModel: colorModel, dismissButtonClosure: { @MainActor [weak sheetPresentation] in
                    sheetPresentation?.dismissSheet()
                })
            )
        }

        sheetPresentation.dismissedClosure = { @MainActor in
            print("custom sheet dismissed!")
        }
    }

    func prepareForAppearance(isVisible: Bool) {
        print("prepareForAppearance - \(String(describing: destination?.type)) : is visible: \(isVisible)")
    }

    func prepareForDisappearance(wasVisible: Bool) {
        print("prepareForDisappearance - \(String(describing: destination?.type)) : was visible: \(wasVisible)")
    }
}
