//
//  SaveToDiskInteractorAssistant.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

/// A custom async interactor assistant which passes the `imageFile` content it receives along to the ``ImageSaverInteractor`` in a ``SaveImageRequest``.
///
/// The default `basicAsync` assistant only forwards an action type, so a custom assistant like this one is necessary when a sequence step's request should include the content produced by the previous step.
struct SaveToDiskInteractorAssistant: AsyncInteractorAssisting, DestinationTypes {

    typealias InteractorType = AppInteractorType
    typealias Request = SaveImageRequest

    let interactorType: InteractorType = .imageSaver
    let requestMethod: InteractorRequestMethod = .async

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: AppContentType?) async -> Result<Request.ResultData, any Error> where Destination.InteractorType == InteractorType {

        let request = SaveImageRequest(action: actionType, dataToSave: buildDataModels(from: content))
        return await destination.performRequest(interactor: interactorType, request: request)
    }

    private func buildDataModels(from content: AppContentType?) -> [DataModel]? {
        guard case .imagesData(let models) = content else { return nil }
        return models
    }
}
