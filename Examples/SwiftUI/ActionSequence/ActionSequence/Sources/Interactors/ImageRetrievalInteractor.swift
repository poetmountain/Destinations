//
//  ImageRetrievalInteractor.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ImageRetrievalRequest: InteractorRequestConfiguring {

    enum ActionType: InteractorRequestActionTypeable {
        case retrieve(imageURL: URL)
    }

    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType

    let action: ActionType

    init(action: ActionType) {
        self.action = action
    }
}

/// An Interactor which retrieves a random image from a remote service. This is the first step of the demo's ActionSequence.
actor ImageRetrievalInteractor: AsyncInteractable {

    typealias Request = ImageRetrievalRequest

    func perform(request: Request) async -> Result<Request.ResultData, any Error> {

        switch request.action {

            case .retrieve(let url):
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)

                    guard let image = UIImage(data: data) else {
                        return .failure(SequenceDemoError.imageDecodingFailed)
                    }

                    return .success(.image(image: image))

                } catch {
                    return .failure(error)
                }
        }
    }
}
