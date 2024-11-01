//
//  ColorsDatasource.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 4/17/24.
//

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


actor ColorsDatasource: AsyncDatasourceable {

    typealias Request = ColorsRequest
    typealias ActionType = Request.ActionType
    typealias ResultData = Request.ResultData

    weak var statusDelegate: (any DatasourceItemsProviderStatusDelegate)?
    
    @Published var items: [ColorViewModel] = []
    
    func startItemsRetrieval() async {
       
    }
    
    
    public func perform(request: Request) async -> Result<[ColorsRequest.ResultData], Error> {
        
        switch request.action {
            case .retrieve, .paginate:
                return await retrieveColors(request: request)
        }
    }
    

    
    func retrieveColors(request: ColorsRequest) async -> Result<[ColorsRequest.ResultData], Error> {
        
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
        let result: Result<[ColorViewModel], Error> = .success(items)
        
        if let statusDelegate = self.statusDelegate as? ColorsDatasourceProviderStatusDelegate {
            statusDelegate.didUpdateItems(with: result)
        }
        
        return result

    }
    

}


protocol ColorsDatasourceProviderStatusDelegate: DatasourceItemsProviderStatusDelegate {
    
    func didUpdateItems(with result: Result<[ColorViewModel], Error>)
}


