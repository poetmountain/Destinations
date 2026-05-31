//
//  BaseViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import SwiftUI
import Destinations

enum GeneralAppEvents: EventTypeable {
    var rawValue: String {
        return ""
    }
}

public enum AppInteractorType: InteractorTypeable {
    case test
}

final class BaseViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
        
    enum Events: EventTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias EventType = Events
    typealias Destination = ControllerDestination<BaseViewController, EventType, DestinationType, ContentType, TabType, InteractorType>
        
    var destinationState: DestinationInterfaceState<Destination>
        
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

final class StartViewController: UINavigationController, NavigationControllerDestinationInterfacing, DestinationTypes {
        
    enum Events: EventTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias EventType = Events
    typealias Destination = NavigationControllerDestination<StartViewController, EventType, DestinationType, ContentType, TabType, InteractorType>
        
    var destinationState: NavigationDestinationInterfaceState<Destination>
        
    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
