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
    func present(colors: [ColorModel], completionClosure: DatasourceResponseClosure<[ColorViewModel]>?) -> Result<[ColorViewModel], Error>
}

struct ColorsRequest: InteractorRequestConfiguring {
    enum ActionType: InteractorRequestActionTypeable {
        case retrieve
        case paginate
    }
    
    typealias ResultData = ColorViewModel

    var action: ActionType
    
    var numColorsToRetrieve: Int = 3
}


final class ColorsDatasource: Datasourceable {
    
    typealias Request = ColorsRequest
    typealias ActionType = Request.ActionType
    typealias ResultData = Request.ResultData
    
    weak var statusDelegate: (any DatasourceItemsProviderStatusDelegate)?
    
    @Published var items: [ColorViewModel] = []

    var itemsProvider: Published<[Request.ResultData]>.Publisher { $items }
    
    let presenter: ColorsPresenting
    
    init(with presenter: ColorsPresenting) {
        self.presenter = presenter
    }
    
    func startItemsRetrieval() {
        perform(request: ColorsRequest(action: .retrieve))
    }
    
    func perform(request: Request, completionClosure: DatasourceResponseClosure<[Request.ResultData]>? = nil) {
        
        switch request.action {
            case .retrieve, .paginate:
                retrieveColors(request: request, completionClosure: completionClosure)
                
        }

    }
    
    func retrieveColors(request: ColorsRequest, completionClosure: DatasourceResponseClosure<[Request.ResultData]>? = nil) {
        
        let red = ColorModel(color: UIColor.red, name: "red")
        let yellow = ColorModel(color: UIColor.yellow, name: "yellow")
        let blue = ColorModel(color: UIColor.blue, name: "blue")
        let orange = ColorModel(color: UIColor.orange, name: "orange")
        let pink = ColorModel(color: UIColor.systemPink, name: "pink")
        let allColors = [red, yellow, blue, orange, pink]
        
        let range: Range<Int> = 0..<request.numColorsToRetrieve
        let colors = Array(allColors[safe: range])
                
        let result = presenter.present(colors: colors, completionClosure: completionClosure)
        switch result {
            case .success(let models):
                self.items = models
            case .failure(_):
                break
        }
        
        if let statusDelegate {
            statusDelegate.didUpdateItems(with: result)
        }
    }
    
    
}

public struct ColorsPresenter: ColorsPresenting {

    @discardableResult func present(colors: [ColorModel], completionClosure: DatasourceResponseClosure<[ColorViewModel]>?) -> Result<[ColorViewModel], Error> {
        let viewModels = colors.map { ColorViewModel(colorID: $0.colorID, color: $0.color, name: $0.name) }
        completionClosure?(.success(viewModels))
        return .success(viewModels)
    }
}
