//
//  TestColorsListState.swift
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations
@testable import DestinationsUIKit

@MainActor protocol TestColorsListStateModeling: StateModeling, AnyObject where Destination == TestColorsDestination {

    typealias EventType = Destination.Events
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var items: [ColorViewModel] { get set }
}


@Observable
final class TestColorsListState: TestColorsListStateModeling {

    weak var destination: Destination?

    var items: [ColorViewModel] = []

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType? = nil) {

        switch type {
            case .color, .moreButton:
                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type, content: content)
                })

            case .retrieveInitialColors:
                break
        }
    }

    func handleInteractorResult<Request>(result: Result<Request.ResultData, any Error>, for request: Request) where Request : InteractorRequestConfiguring {
        switch result {
            case .success(let content):
                if case .colors(models: let models) = content as? AppContentType {
                    items = models
                    destination?.controller?.updateItems(items: models)
                }
            case .failure(let error):
                destination?.logError(error: error)
        }
    }

    func configureInteractor(_ interactor: any AbstractInteractable, type: InteractorType) {
        guard let datasource = interactor as? TestColorsDatasource else { return }

        let responseClosure: InteractorResponseClosure<ColorsRequest> = { [weak self] result, request in
            self?.handleInteractorResult(result: result, for: request)
        }
        datasource.assignResponseForAction(response: responseClosure, for: .retrieve)
        datasource.assignResponseForAction(response: responseClosure, for: .paginate)
    }

    func prepareForPresentation() {
        destination?.handleThrowable(closure: { [weak destination] in
            try destination?.performAction(for: .retrieveInitialColors)
        })
    }
}
