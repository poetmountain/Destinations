//
//  ImageFileTransformer.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

/// A custom action sequence Transformer which transforms an array of UIImages into a data model.
///
/// It transforms the `images` content produced by the group step's ``RetrievedImagesMerger`` into `DataModel` objects to be used in saving the images to disk. It pairs each image with a generated file name, which the ``SaveToDiskInteractor`` save step expects as its input.
struct ImageFileTransformer: ContentTransformable {

    func transform(input: AppContentType) throws -> AppContentType {
        let timestamp = Int(Date().timeIntervalSince1970)

        switch input {
        case .image(let image):
            guard let data = image.pngData() else {
                throw SequenceDemoError.invalidImage
            }
            let fileName = "fetched-image-\(timestamp)-\(UUID().uuidString.prefix(8)).png"
            return .imagesData(models: [DataModel(data: data, fileName: fileName)])

        case .images(let images):
            let models: [DataModel] = try images.enumerated().map { index, image in
                guard let data = image.pngData() else {
                    throw SequenceDemoError.invalidImage
                }
                return DataModel(data: data, fileName: "fetched-image-\(timestamp)-\(index).png")
            }
            return .imagesData(models: models)

        default:
            return input
        }
    }
}
