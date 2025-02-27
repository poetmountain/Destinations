//
//  ColorsDatasource.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Combine
import Destinations

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

actor ColorsDatasource: AsyncDatasourceable {
    
    typealias Request = ColorsRequest
    typealias Item = Request.Item
            
    weak var statusDelegate: (any DatasourceItemsProviderStatusDelegate)?
    
    @Published var items: [Item] = []
    

    public func perform(request: Request) async -> Result<ColorsRequest.ResultData, Error> {
        
        switch request.action {
            case .retrieve, .paginate:
                return await retrieveColors(request: request)
        }
    }
    

    func retrieveColors(request: ColorsRequest) async -> Result<AppContentType, Error> {
        
        let red = ColorModel(color: UIColor.systemRed, name: "red")
        let yellow = ColorModel(color: UIColor.systemYellow, name: "yellow")
        let blue = ColorModel(color: UIColor.systemBlue, name: "blue")
        let orange = ColorModel(color: UIColor.orange, name: "orange")
        let pink = ColorModel(color: UIColor.systemPink, name: "pink")
        
        var allColors: [ColorModel] = []
        
        switch request.action {
            case .retrieve:
                allColors = [red, yellow, blue]
            case .paginate:
                allColors = [orange, pink]
        }
                                
        let range: Range<Int> = 0..<request.numColorsToRetrieve
        let colors = Array(allColors[safe: range])
                
        let viewModels = colors.map { ColorViewModel(colorID: $0.colorID, color: $0.color, name: $0.name) }
        self.items.append(contentsOf: viewModels)
        let result: Result<AppContentType, Error> = .success(AppContentType.colors(model: items))
        
        if let statusDelegate = self.statusDelegate as? ColorsDatasourceProviderStatusDelegate {
            statusDelegate.didUpdateItems(with: result)
        }
        
        return result

    }
    

}


protocol ColorsDatasourceProviderStatusDelegate: DatasourceItemsProviderStatusDelegate {
    
    func didUpdateItems(with result: Result<[ColorViewModel], Error>)
}


