//
//  SceneDelegate.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    private(set) static var shared: SceneDelegate?

    var navigationController = UINavigationController()

    var rootController: UIViewController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createRootViewController()
        window?.makeKeyAndVisible()

        DestinationsSupport.logger.options.maximumOutputLevel = .verbose
        
        Self.shared = self
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    
    func createRootViewController() -> UIViewController {
        if isAppRunningTests() {
            let baseVC = BaseTestsViewController()
            rootController = baseVC
            return baseVC
            
        } else {
            let destination = ControllerDestination<BaseViewController, BaseViewController.UserInteractions, BaseViewController.DestinationType, BaseViewController.ContentType, BaseViewController.TabType, BaseViewController.InteractorType>(destinationType: .home)
            let baseVC = BaseViewController(destination: destination)
            destination.assignAssociatedController(controller: baseVC)
            rootController = baseVC
            return baseVC
        }
    }

    func isAppRunningTests() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    }
}

final class BaseTestsViewController: UINavigationController, ControllerDestinationInterfacing, DestinationTypes {

    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }

    
    typealias UserInteractionType = UserInteractions
    typealias Destination = ControllerDestination<BaseViewController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>
    
    var destinationState: DestinationInterfaceState<Destination>
    
    init() {
        let destination = ControllerDestination<BaseViewController, UserInteractionType, DestinationType, AppContentType, TabType, InteractorType>(destinationType: .home)
        destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
