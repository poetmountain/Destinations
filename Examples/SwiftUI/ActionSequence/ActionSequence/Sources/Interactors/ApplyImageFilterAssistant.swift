//
//  ApplyImageFilterAssistant.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

/// A custom async interactor assistant which passes the `imageFile` content it receives along to the ``ApplyImageFilterInteractor`` in a ``ApplyImageFilterRequest``.
///
/// The default `basicAsync` assistant only forwards an action type, so a custom assistant like this one is necessary when a sequence step's request should include the content produced by the previous step.
struct ApplyImageFilterAssistant: AsyncInteractorAssisting, DestinationTypes {

    typealias InteractorType = AppInteractorType
    typealias Request = ApplyImageFilterRequest

    let interactorType: InteractorType = .imageFilter
    let requestMethod: InteractorRequestMethod = .async

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: AppContentType?) async -> Result<Request.ResultData, any Error> where Destination.InteractorType == InteractorType {

        let request = ApplyImageFilterRequest(action: actionType, imageURLs: extractValues(from: content))
        return await destination.performRequest(interactor: interactorType, request: request)
    }

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: AppContentType?) async where Destination.InteractorType == InteractorType {

        let request = ApplyImageFilterRequest(action: actionType, imageURLs: extractValues(from: content))
        let result = await destination.performRequest(interactor: interactorType, request: request)
        await destination.handleAsyncInteractorResult(result: result, for: request)
    }

    private func extractValues(from content: AppContentType?) -> [URL]? {
        guard case .savedFiles(urls: let urls) = content else { return nil }
        return urls
    }
}
