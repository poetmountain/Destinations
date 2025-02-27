//
//  ColorsRequest.swift
//  DestinationsUIKit
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

protocol ColorsPresenting {
    func present(colors: [ColorModel], response: InteractorResponseClosure<ColorsRequest>?, request: ColorsRequest) -> Result<ColorsRequest.ResultData, Error>
}

struct ColorsRequest: InteractorRequestConfiguring {

    enum ActionType: InteractorRequestActionTypeable {
        case retrieve
        case paginate
    }
    
    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType
    typealias Item = ColorViewModel
    
    let action: ActionType
    
    var numColorsToRetrieve: Int = 3
    
    init(action: ActionType) {
        self.action = action
    }
    
    init(action: ActionType, numColorsToRetrieve: Int) {
        self.action = action
        self.numColorsToRetrieve = numColorsToRetrieve
    }
    
}
