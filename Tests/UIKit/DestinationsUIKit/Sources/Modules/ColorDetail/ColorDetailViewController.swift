//
//  ColorDetailViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class ColorDetailViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
    
    typealias UserInteractionType = ColorDetailDestination.UserInteractions
    typealias Destination = ColorDetailDestination
        
    var destinationState: DestinationInterfaceState<Destination>
    
    var colorModel: ColorViewModel?
    
    static let typedNil : Int? = nil
    
    init(destination: Destination, colorModel: ColorViewModel? = nil) {
        self.destinationState = DestinationInterfaceState(destination: destination)

        self.colorModel = colorModel
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
        view.backgroundColor = colorModel?.color
        
        let button = PillButton()
        button.titleLabel?.text = "Present sheet"
        button.backgroundColor = .init(white: 1.0, alpha: 0.9)
        button.foregroundColor = .blue
        button.tapAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.handleDetailTap()
        }
        
    
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

    }
    
    func handleDetailTap() {
        guard let colorModel else { return }
        destination().handleThrowable { [weak self] in
            try self?.destination().performInterfaceAction(interactionType: .colorDetailButton(model: colorModel))
        }
    }


}
