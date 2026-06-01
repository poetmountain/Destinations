//
//  ColorsDatasource.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

struct ColorModel: Hashable {
    let colorID: UUID = UUID()
    let color: UIColor
    let name: String?
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


actor ColorsDatasource: AsyncInteractable {
    
    typealias Request = ColorsRequest
    typealias Item = Request.Item
    
    var items: [Item] = []

    func perform(request: Request) async -> Result<ColorsRequest.ResultData, Error> {
        
        switch request.action {
            case .retrieve, .paginate:
                return await retrieveColors(request: request)
        }
    }
    
    func retrieveColors(request: ColorsRequest) async -> Result<AppContentType, Error> {
        
        let red = ColorModel(color: UIColor.red, name: "red")
        let yellow = ColorModel(color: UIColor.yellow, name: "yellow")
        let blue = ColorModel(color: UIColor.blue, name: "blue")
        let orange = ColorModel(color: UIColor.orange, name: "orange")
        let pink = ColorModel(color: UIColor.systemPink, name: "pink")
        let allColors = [red, yellow, blue, orange, pink]
        
        let range: Range<Int> = 0..<request.numColorsToRetrieve
        let colors = Array(allColors[safe: range])
        
        let viewModels = colors.map { ColorViewModel(colorID: $0.colorID, color: $0.color, name: $0.name) }
        self.items = viewModels
        let result: Result<AppContentType, Error> = .success(.colors(models: viewModels))
        
        return result
    }
    
}
