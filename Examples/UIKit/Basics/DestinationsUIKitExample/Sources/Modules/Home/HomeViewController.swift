//
//  HomeViewController.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 8/26/24.
//

import UIKit
import Destinations

final class HomeViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
 
    typealias UserInteractionType = HomeUserInteractions
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = ControllerDestination<UserInteractionType, HomeViewController, PresentationConfiguration, InteractorType>
        
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
        
        let button = PillButton()
        button.titleLabel?.text = "Display nested path in other tab"
        button.tapAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.handleButtonTap()
        }
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    func handleButtonTap() {
        destination().handleThrowable { [weak self] in
            try self?.destination().performInterfaceAction(interactionType: .pathPresent)
        }
    }

}

