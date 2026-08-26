//
//  AppContentType.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

enum AppContentType: ContentTypeable {

    case none
    
    /// A single image retrieved.
    case image(image: UIImage)

    /// A set of retrieved images, combined into one value by the ``RetrievedImagesMerger``.
    case images(images: [UIImage])

    /// The retrieved images paired with file names, ready to be saved by the ``SaveToDiskInteractor``. This content is produced by the ``ImageFileTransformer`` transformer.
    case imagesData(models: [DataModel])

    /// The locations of the images which were saved to disk.
    case savedFiles(urls: [URL])

    var rawValue: String {
        switch self {
            case .none:
                return "none"
            case .image:
                return "image"
            case .images:
                return "images"
            case .imagesData:
                return "imagesData"
            case .savedFiles:
                return "savedFiles"
        }
    }
}

extension AppContentType: Equatable {
    public static func == (lhs: AppContentType, rhs: AppContentType) -> Bool {
        return (lhs.rawValue == rhs.rawValue)
    }
}
