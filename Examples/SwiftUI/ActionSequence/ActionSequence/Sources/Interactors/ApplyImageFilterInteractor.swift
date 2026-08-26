//
//  ApplyImageFilterInteractor.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct ApplyImageFilterRequest: InteractorRequestConfiguring {

    enum ActionType: InteractorRequestActionTypeable {
        case filter
    }

    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType

    let action: ActionType

    /// The image files which should be 
    var imageURLs: [URL]?

    init(action: ActionType) {
        self.action = action
    }

    init(action: ActionType, imageURLs: [URL]?) {
        self.action = action
        self.imageURLs = imageURLs
    }
}

actor ApplyImageFilterInteractor: AsyncInteractable {
    
    typealias Request = ApplyImageFilterRequest

    func perform(request: Request) async -> Result<Request.ResultData, any Error> {

        switch request.action {
            case .filter:
                guard let imageURLs = request.imageURLs, imageURLs.isEmpty == false else {
                    return .failure(SequenceDemoError.missingImageFile)
                }
                
                for x in 0..<imageURLs.count {
                    let imageURL = imageURLs[x]
                    
                    var data: Data
                    do {
                        data = try Data(contentsOf: imageURL)
                    } catch {
                        return .failure(SequenceDemoError.invalidImageURL)
                    }
                    guard let image = CIImage(data: data) else {
                        return .failure(SequenceDemoError.imageDecodingFailed)
                    }
                    
                    let filter = CIFilter.sepiaTone()
                    filter.inputImage = image
                    filter.intensity = 1.0

                    let context = CIContext()
                    guard let outputCIImage = filter.outputImage,
                          let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                        return .failure(SequenceDemoError.imageDecodingFailed)
                    }
                    
                    // filter the image and save to the same file URL
                    let uiImage = UIImage(cgImage: cgImage)
                    if let filteredData = uiImage.jpegData(compressionQuality: 0.9) {
                        do {
                            try filteredData.write(to: imageURL)
                        } catch {
                            return .failure(error)
                        }
                        
                    }
                }

                return .success(.savedFiles(urls: imageURLs))
        }
    }

}
