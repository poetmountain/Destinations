//
//  ColorsResultTransformer.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

/// Converts `ColorsResult` into `AppContentType`'s `.colors` case. Supplied as the `result` transformer for `InteractorAssistantType.transformer(request:result:)` in `ColorsListProvider`.
struct ColorsResultTransformer: ContentTransformable {
    func transform(input: ColorsResult) throws -> AppContentType {
        switch input {
            case .retrievedColors(let models):
                return .colors(models: models)
        }
    }
}
