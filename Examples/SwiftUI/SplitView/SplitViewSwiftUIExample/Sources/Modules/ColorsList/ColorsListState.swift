//
//  ColorsListState.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

/// Demonstrates the ability to swap state models by using a protocol
@MainActor protocol ColorsListStateModeling: StateModeling, AnyObject, Identifiable {

    var id: UUID { get }

    var items: [ColorViewModel] { get set }

    var selectedItem: ColorViewModel.ID? { get set }
}


@Observable
final class ColorsListState: ColorsListStateModeling {
    typealias Destination = ColorsListView.Destination
    typealias EventType = ColorsListView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    let id = UUID()

    var destination: Destination?

    var items: [ColorViewModel] = []

    var selectedItem: ColorViewModel.ID?

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType?) {
        destination?.handleThrowable(closure: { [weak destination] in
            try destination?.performAction(for: type, content: content)
        })
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
        destination?.handleThrowable(closure: { [weak destination] in
            try destination?.performAction(for: .retrieveInitialColors)
        })
    }
}
