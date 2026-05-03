//
//  HomeViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class HomeViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
 
    typealias UserInteractionType = HomeUserInteractions
    typealias InteractorType = AppInteractorType
    typealias Destination = ControllerDestination<HomeViewController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>
        
    var destinationState: DestinationInterfaceState<Destination>

    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemIndigo
        
    }

}

