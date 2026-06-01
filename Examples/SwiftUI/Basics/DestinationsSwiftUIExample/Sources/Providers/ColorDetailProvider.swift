//
//  ColorDetailProvider.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorDetailProvider: ViewDestinationProviding, DestinationTypes {

    public typealias Destination = ColorDetailView.Destination

    public var presentationsData: [Destination.EventType: DestinationPresentation<DestinationType, AppContentType, TabType>] = [:]
    public var interactorsData: [Destination.EventType : any InteractorConfiguring<Destination.InteractorType>] = [:]

    init() {
        let options = ViewSheetPresentationOptions(presentationMode: .sheet)
        let sheetPresent = DestinationPresentation<DestinationType, ContentType, TabType>(
            destinationType: .dynamic,
            presentationType: .sheet(type: .present, options: SheetPresentationOptions(swiftUI: options)),
            assistantType: .basic)

        presentationsData = [.colorDetailButton: sheetPresent]
    }

    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.EventType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {

        var colorModel: ColorViewModel?
        if let contentType = configuration.contentType, case let .color(model) = contentType {
            colorModel = model
        }

        let state = ColorDetailState(colorModel: colorModel)
        let destination = Destination(destinationType: .colorDetail, destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let view = ColorDetailView(destination: destination, state: state)

        let sheetView = ContainerView {
            AnyView(
                ColorSheetView(colorModel: colorModel, dismissButtonClosure: { [weak sheetPresentation = view.sheetPresentation] in
                    sheetPresentation?.dismissSheet()
                })
            )
        }

        state.sheetView = sheetView
        destination.assignAssociatedView(view: view)

        return destination

    }

}
