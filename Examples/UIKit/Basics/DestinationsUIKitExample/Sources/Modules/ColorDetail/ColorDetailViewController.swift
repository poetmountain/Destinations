//
//  ColorDetailViewController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

@Observable
final class ColorDetailInterfaceState: DestinationStateable, DestinationTypes {

    @AutoCaseIterable
    enum Events: EventTypeable {
        case colorDetailButton
        case customDetailButton

        var rawValue: String {
            switch self {
                case .colorDetailButton:
                    return "colorDetailButton"
                case .customDetailButton:
                    return "customDetailButton"
            }
        }

        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    typealias Destination = ControllerDestination<ColorDetailViewController, Events, DestinationType, AppContentType, TabType, InteractorType>

    var destination: Destination

    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
        self.destination.stateModel = state
    }
}

final class ColorDetailViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {

    typealias EventType = ColorDetailInterfaceState.Events
    typealias InteractorType = ColorDetailInterfaceState.InteractorType
    typealias Destination = ColorDetailInterfaceState.Destination

    var destinationState: ColorDetailInterfaceState

    init(destination: Destination, state: ColorDetailState) {
        self.destinationState = ColorDetailInterfaceState(destination: destination, state: state)
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
        view.backgroundColor = stateModel.colorModel?.color
        
        let button = PillButton()
        button.titleLabel?.text = "Present sheet"
        button.backgroundColor = .init(white: 1.0, alpha: 0.9)
        button.foregroundColor = .blue
        button.tapAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.handleDetailTap()
        }
        
        let customButton = PillButton()
        customButton.titleLabel?.text = "Custom sheet"
        customButton.backgroundColor = .init(white: 1.0, alpha: 0.9)
        customButton.foregroundColor = .blue
        customButton.tapAction { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.handleCustomDetailTap()
        }
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(customButton)
        customButton.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            customButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20),
            customButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

    }
    
    func handleDetailTap() {
        guard let colorModel = stateModel.colorModel else { return }
        stateModel.handleEvent(.colorDetailButton, content: .color(model: colorModel))
    }

    func handleCustomDetailTap() {
        guard let colorModel = stateModel.colorModel else { return }
        stateModel.handleEvent(.customDetailButton, content: .color(model: colorModel))
    }

}
