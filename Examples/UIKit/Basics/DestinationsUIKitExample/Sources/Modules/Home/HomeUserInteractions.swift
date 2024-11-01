//
//  HomeUserInteractions.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 9/24/24.
//

import Foundation
import Destinations

enum HomeUserInteractions: UserInteractionTypeable {
    case replaceView
    case pathPresent
    
    var rawValue: String {
        switch self {
            case .replaceView:
                return "replaceView"
            case .pathPresent:
                return "pathPresent"
        }
    }
}
