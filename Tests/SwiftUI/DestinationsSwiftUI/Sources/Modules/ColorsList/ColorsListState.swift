//
//  ColorsListState.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@MainActor protocol ColorsListStateModeling: StateModeling, AnyObject, Identifiable where Destination == ColorsListDestination {

    typealias EventType = Destination.Events
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var id: UUID { get }

    var items: [ColorViewModel] { get set }

    var selectedItem: ColorViewModel.ID? { get set }
}


@Observable
final class ColorsListState: ColorsListStateModeling {

    let id = UUID()

    var destination: Destination?

    var items: [ColorViewModel] = []

    var selectedItem: ColorViewModel.ID?

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType? = nil) {
        switch type {
            case .color(model: _):
                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                })
            case .retrieveInitialColors:
                break
        }
    }

    func handleAsyncInteractorResult<Request>(result: Result<Request.ResultData, any Error>, for request: Request) async where Request : InteractorRequestConfiguring {
        switch result {
            case .success(let content):
                if case .colors(models: let models) = content as? AppContentType {
                    items = models
                }
            case .failure(let error):
                DestinationsSupport.logger.log("error \(error.localizedDescription)", category: .error)
        }
    }

    func prepareForPresentation() {
        // retrieve initial colors
        destination?.handleThrowable(closure: { [weak destination] in
            try destination?.performAction(for: .retrieveInitialColors)
        })
    }
}
