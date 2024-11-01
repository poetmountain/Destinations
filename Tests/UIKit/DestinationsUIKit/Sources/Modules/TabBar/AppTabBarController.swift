//
//  AppTabBarController.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

final class AppTabBarController: UITabBarController, TabBarControllerDestinationInterfacing, DestinationTypes {
    
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = RouteDestinationType
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = DestinationPresentation<RouteDestinationType, AppContentType, TabType>
    typealias Destination = TabBarControllerDestination<PresentationConfiguration, AppTabBarController>

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

        setupTabBar()
    }
    
    func setupTabBar() {
        tabBar.unselectedItemTintColor = .black
        tabBar.tintColor = .systemBlue

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment =  UIOffset(horizontal: 0, vertical: -16)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 18)]
        
        appearance.stackedItemPositioning = .centered
        appearance.stackedItemWidth = 90

        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    
    func customizeTabItem(for tab: TabType, navigationController: UINavigationController) {
        navigationController.tabBarItem = UITabBarItem(title: tab.tabName,
                                            image: nil,
                                            selectedImage: nil)
                                .tabBarItemShowingOnlyText()
    }


}
