//
//  SheetViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class SheetViewController: UINavigationController, NavigationControllerDestinationInterfacing, DestinationTypes {
    enum UserInteractions: UserInteractionTypeable {
        case color
        
        var rawValue: String {
            switch self {
                case .color:
                    return "color"
            }
        }
    }

    typealias UserInteractionType = UserInteractions
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = SheetDestination
        
    var destinationState: DestinationInterfaceState<Destination>

    init(destination: Destination, rootController: UIViewController) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(rootViewController: rootController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func endAppearanceTransition() {
        let destination = destination()
        
        if isBeingDismissed && !destination.isSystemNavigating {
            destination.performSystemNavigationAction(navigationType: .dismissSheet, options: SystemNavigationOptions(targetID: destination.id, parentID: destination.parentDestinationID))
         }
         super.endAppearanceTransition()
     }
    
}

final class SheetContentViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
    

    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }

    typealias UserInteractionType = UserInteractions
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = SheetDestination
    
    var destinationState: DestinationInterfaceState<Destination>

    lazy var circleView: CircleView = {
        return CircleView()
    }()
    
    lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    var content: ContentType?

    init(destination: Destination, content: ContentType? = nil) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
               
       setupUI()
        
        if let content {
            switch content {
                case .color(model: let model):
                    circleView.backgroundColor = model.color
                    colorLabel.text = model.name?.capitalized
                    
                default: break
            }
        }
    }
   
    private func setupUI() {
        view.backgroundColor = .systemGray6

        let button = PillButton()
        button.titleLabel?.text = "Dismiss"
        button.tapAction { [weak self] in
           guard let strongSelf = self else { return }
           strongSelf.handleButtonTap()
        }

        view.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 160),
            circleView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        view.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.bottomAnchor.constraint(equalTo: circleView.topAnchor, constant: -10),
            colorLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor)
        ])

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
       
    }
   
    func handleButtonTap() {
        if let navigationController = navigationController as? SheetViewController {
            let navDestination = navigationController.destination()
            navDestination.performSystemNavigationAction(navigationType: .dismissSheet, options: SystemNavigationOptions(targetID: navDestination.id, parentID: navDestination.parentDestinationID))
        }

       
    }

    override func endAppearanceTransition() {
        let destination = destination()
        
        if isBeingDismissed && !destination.isSystemNavigating {
            destination.performSystemNavigationAction(navigationType: .dismissSheet, options: SystemNavigationOptions(targetID: destination.id, parentID: destination.parentDestinationID))
         }
         super.endAppearanceTransition()
     }

}

final class CircleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = frame.size.height / 2
    }
    
    private func setupUI() {
        self.layer.masksToBounds = true
    }
}
