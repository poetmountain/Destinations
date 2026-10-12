//
//  ColorsRequestTransformer.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

/// Converts `AppContentType` into `ColorsRequestContent`, letting `ColorsListView`'s "Show More" button request a specific number of colors (via `.count(value:)`) without `ColorsRequest` needing to know about `AppContentType` directly. Supplied as the `request` transformer for `InteractorAssistantType.transformer(request:result:)` in `ColorsListProvider`.
struct ColorsRequestTransformer: ContentTransformable {
    func transform(input: AppContentType) throws -> ColorsRequestContent {
        if case .colorsRequest(requestModel: let model) = input {
            return model
        }
        return .numColorsToRetrieve(3)
    }
}
