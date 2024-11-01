//
//  AppTabType.swift
//  DestinationsSwiftUI
//
//  Created by Brett Walker on 6/28/24.
//

import Foundation
import Destinations

public enum AppTabType: String, TabTypeable {
    case palettes
    case home
    case swiftUI
    
    public var tabName: String {
        switch self {
            case .palettes:
                return "Palettes"
            case .home:
                return "Home"
            case .swiftUI:
                return "SwiftUI"
        }
    }

}
