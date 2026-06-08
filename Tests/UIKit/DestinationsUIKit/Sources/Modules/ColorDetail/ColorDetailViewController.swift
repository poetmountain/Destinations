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
final class ColorDetailInterfaceState: DestinationStateable {
    typealias Destination = ColorDetailDestination

    var destination: Destination

    var stateModel: ColorDetailState

    init(destination: Destination, state: ColorDetailState) {
        self.destination = destination
        self.stateModel = state
        self.destination.stateModel = state
    }
}

final class ColorDetailViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {

    typealias EventType = ColorDetailDestination.Events
    typealias Destination = ColorDetailDestination

    var destinationState: ColorDetailInterfaceState

    static let typedNil : Int? = nil

    init(destination: Destination, state: ColorDetailState = ColorDetailState()) {
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

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

    }

    func handleDetailTap() {
        guard let colorModel = stateModel.colorModel else { return }
        stateModel.handleEvent(.colorDetailButton(model: colorModel), content: nil)
    }


}
