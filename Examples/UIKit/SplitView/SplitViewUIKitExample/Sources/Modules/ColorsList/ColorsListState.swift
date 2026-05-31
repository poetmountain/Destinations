//
//  ColorsListState.swift
//  SplitViewUIKitExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@MainActor protocol ColorsListStateModeling: StateModeling, AnyObject {

    var items: [ColorViewModel] { get set }
}


@Observable
final class ColorsListState: ColorsListStateModeling {
    typealias Destination = ColorsViewController.Destination
    typealias EventType = ColorsViewController.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    weak var destination: Destination?

    var items: [ColorViewModel] = []

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType?) {

        switch type {
            case .color:
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
                if case .colors(model: let models) = content as? AppContentType {
                    items = models
                    destination?.controller?.updateItems(items: models)
                }
            case .failure(let error):
                destination?.logError(error: error)
        }
    }

    func prepareForPresentation() {
        // load initial color models from datasource
        destination?.handleThrowable(closure: { [weak destination] in
            try destination?.performAction(for: .retrieveInitialColors)
        })
    }
}
