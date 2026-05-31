//
//  StartViewController.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class StartViewController: UINavigationController, NavigationControllerDestinationInterfacing, AppDestinationTypes {
        
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
