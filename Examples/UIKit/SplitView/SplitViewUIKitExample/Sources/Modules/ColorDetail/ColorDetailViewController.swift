//
//  ColorDetailViewController.swift
//  SplitViewUIKitExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

final class ColorDetailViewController: UIViewController, ControllerDestinationInterfacing, AppDestinationTypes {
    
    typealias UserInteractionType = ColorDetailDestination.UserInteractions
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = ColorDetailDestination
        
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
        
        if let colorModel {
            circleView.backgroundColor = colorModel.color
            colorLabel.text = colorModel.name?.capitalized
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemGray6

        view.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 200),
            circleView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        view.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.bottomAnchor.constraint(equalTo: circleView.topAnchor, constant: -10),
            colorLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor)
        ])

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
