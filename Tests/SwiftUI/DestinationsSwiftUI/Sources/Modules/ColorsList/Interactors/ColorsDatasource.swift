//
//  ColorsDatasource.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
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

    var items: [Item] = []

    func perform(request: Request) async -> Result<ColorsRequest.ResultData, Error> {

        switch request.action {
            case .retrieve, .paginate:
                return await retrieveColors(request: request)
        }
    }

    func retrieveColors(request: ColorsRequest) async -> Result<AppContentType, Error> {
        var allColors: [ColorModel] = []

        let range: Range<Int> = 0..<request.numColorsToRetrieve

        switch request.action {
            case .retrieve:
                let red = ColorModel(color: UIColor.red, name: "red")
                let yellow = ColorModel(color: UIColor.yellow, name: "yellow")
                let blue = ColorModel(color: UIColor.blue, name: "blue")
                allColors = [red, yellow, blue]
            case .paginate:
                allColors = range.map { _ in randomHexColor() }
        }

        let colors = Array(allColors[safe: range])

        let viewModels = colors.map { ColorViewModel(colorID: $0.colorID, color: $0.color, name: $0.name) }
        self.items.append(contentsOf: viewModels)
        let result: Result<AppContentType, Error> = .success(.colors(models: items))

        return result
    }

    private func randomHexColor() -> ColorModel {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        let hexName = String(format: "#%02X%02X%02X", red, green, blue)
        let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        return ColorModel(color: color, name: hexName)
    }

}
