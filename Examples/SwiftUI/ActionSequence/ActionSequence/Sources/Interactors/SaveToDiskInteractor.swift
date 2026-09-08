//
//  SaveToDiskInteractor.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct SaveImageRequest: InteractorRequestConfiguring {

    enum ActionType: InteractorRequestActionTypeable {
        case save
    }

    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType

    let action: ActionType

    /// The image files which should be written to disk.
    var dataModels: [DataModel]?

    init(action: ActionType) {
        self.action = action
    }

    init(action: ActionType, dataToSave: [DataModel]?) {
        self.action = action
        self.dataModels = dataToSave
    }

    init(action: ActionType, content: AppContentType?) {
        self.action = action
        if case .imagesData(let models) = content {
            dataModels = models
        }
    }
}

/// An Interactor which saves images to the app's Documents directory. This is the final step of the demo's ActionSequence, saving all of the images retrieved in parallel by the group step.
actor SaveToDiskInteractor: AsyncInteractable {

    typealias Request = SaveImageRequest

    func perform(request: Request) async -> Result<Request.ResultData, any Error> {

        switch request.action {
            case .save:
                guard let dataToSave = request.dataModels, dataToSave.isEmpty == false else {
                    return .failure(SequenceDemoError.missingImageFile)
                }

                do {
                    let directoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

                    var savedURLs: [URL] = []
                    for model in dataToSave {
                        let fileURL = directoryURL.appendingPathComponent(model.fileName)
                        try model.data.write(to: fileURL)
                        savedURLs.append(fileURL)
                    }

                    return .success(.savedFiles(urls: savedURLs))

                } catch {
                    return .failure(error)
                }
        }
    }
}
