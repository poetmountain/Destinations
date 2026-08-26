//
//  RetrievedImagesMerger.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

/// Merges the results of the demo's ``ActionGroup`` — several retrieve-and-save child sequences running in parallel — into a single `savedFiles` content value.
///
/// Each child sequence retrieves one image and saves it to disk, producing a `.savedFiles([URL])` result. This merger flattens all per-child URL arrays into one combined array.
struct RetrievedImagesMerger: ActionResultsMerging {

    func merge(results: [ActionResult<AppContentType>]) throws -> AppContentType {

        let allURLs: [URL] = results.flatMap { result in
            guard case .savedFiles(let urls) = result.content else {
                return [URL]()
            }
            return urls
        }

        return .savedFiles(urls: allURLs)
    }
}
