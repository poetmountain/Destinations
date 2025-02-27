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

protocol ColorsPresenting {
    func present(colors: [ColorModel]) -> Result<[ColorViewModel], Error>
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


final class ColorsDatasource: Datasourceable {
    
    typealias Request = ColorsRequest
    typealias Item = Request.Item

    var requestResponses: [Request.ActionType: InteractorResponseClosure<Request>] = [:]

    weak var statusDelegate: (any DatasourceItemsProviderStatusDelegate)?
    
    @Published var items: [Item] = []

    var itemsProvider: Published<[Request.Item]>.Publisher { $items }
    
    let presenter: ColorsPresenting
    
    init(with presenter: ColorsPresenting) {
        self.presenter = presenter
    }
    

    func perform(request: Request) {
        
        switch request.action {
            case .retrieve, .paginate:
                retrieveColors(request: request)
                
        }

    }
    
    func retrieveColors(request: ColorsRequest) {
        
        let red = ColorModel(color: UIColor.red, name: "red")
        let yellow = ColorModel(color: UIColor.yellow, name: "yellow")
        let blue = ColorModel(color: UIColor.blue, name: "blue")
        let orange = ColorModel(color: UIColor.orange, name: "orange")
        let pink = ColorModel(color: UIColor.systemPink, name: "pink")
        let allColors = [red, yellow, blue, orange, pink]
        
        let range: Range<Int> = 0..<request.numColorsToRetrieve
        let colors = Array(allColors[safe: range])
                
        let result = presenter.present(colors: colors)
        let response = responseForAction(action: request.action)

        switch result {
            case .success(let models):
                self.items = models
                
                response?(.success(.colors(models: models)), request)
            case .failure(_):
                break
        }

    }
    
    
}

public struct ColorsPresenter: ColorsPresenting {

    @discardableResult func present(colors: [ColorModel]) -> Result<[ColorViewModel], Error> {
        let viewModels = colors.map { ColorViewModel(colorID: $0.colorID, color: $0.color, name: $0.name) }
        return .success(viewModels)
    }
}
