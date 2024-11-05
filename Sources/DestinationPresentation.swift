//
//  DestinationPresentation.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

///  This is a model used to configure how a Destination is presented or removed. It contains information such as the type of Destination to present, the type of presentation to be made, and the type of content to pass along. They are typically associated with a particular ``InterfaceAction`` and used to trigger a new presentation when a user interaction is made with the current UI.
///
///  Destinations has several built-in presentation types which `DestinationPresentation` supports to enable native SwiftUI and UIKit UI navigation, as well as more complex or custom behavior.
///
///  * `navigationController(type: NavigationPresentationType)` This presentation type will add and present a Destination in a navigation stack such as a `UINavigationController` or SwiftUI's `NavigationStack`.
///  * `tabBar(tab: TabType)` This presentation type will present a Destination in the specified tab of a tab bar component, such as a `UITabBarController` or SwiftUI's `TabView`. If no `destinationType` is present in the `DestinationPresentation` model, the specified tab will simply be selected, becoming the active tab within the interface.
///  * `addToCurrent` This presentation type adds a Destination as a child of the currently-presented Destination. Note that this type only works with UIKit and utilizes `UIViewController`'s `addChild` method.
///  * `replaceCurrent` This presentation type replaces the currently-presented Destination with a new Destination in system UI components which allow that.
///  * `sheet(type: SheetPresentationType, options: SheetPresentationOptions?)` This presentation type presents (or dismisses) a Destination in a sheet. The `options` parameter allows you to customize how the sheet is presented, configuring SwiftUI-specific options with a `ViewSheetPresentationOptions` model and UIKit-specific options with a `ControllerSheetPresentationOptions` model.
///  * `destinationPath(path: [DestinationPresentation])` This presentation type presents a path of multiple Destination objects, useful for providing deep linking functionality or building complex state with one user interaction.
///  * `custom(presentation: CustomPresentation<DestinationPresentation>)` This presentation type enables you to present a custom presentation of a Destination. It can be used to support the presentation of custom UI, as well as system components which Destinations does not directly support. The `presentation` parameter allows you to use a `CustomPresentation` model with specialized closures to provide whatever functionality you need.
public final class DestinationPresentation<DestinationType: RoutableDestinations, ContentType: ContentTypeable, TabType: TabTypeable>: DestinationPresentationConfiguring {
    public typealias DestinationType = DestinationType
    public typealias ContentType = ContentType
    public typealias TabType = TabType

    /// A unique identifier.
    public let id = UUID()
    
    /// An enum representing the type of Destination to be presented.
    public var destinationType: DestinationType?
    
    /// An enum type representing the way this Destination should be presented.
    public let presentationType: PresentationType
    
    /// An enum type representing the content to be used with this presentation.
    public var contentType: ContentType?
    
    /// An enum representing the type of action used with this presentation.
    public var actionType: DestinationActionType
        
    /// The unique identifier of the target of this presentation, if one exists.
    public var actionTargetID: UUID?

    /// The type of `InterfaceAction` assistant to be used to configure this presentation.
    public var assistantType: ActionAssistantType
    
    /// The unique identifier of the currently presented Destination.
    public var currentDestinationID: UUID?

    /// The unique identifier of the parent of the Destination to be presented.
    public var parentDestinationID: UUID?
    
    /// The ``DestinationPathNavigating`` object associated with the Destination to be presented.
    public var navigator: (any DestinationPathNavigating)?
    
    /// An options model that configures how a Destination is presented within a navigation stack. Currently this only applies to UIKit navigation controller presentations.
    public var navigationStackOptions: NavigationStackPresentationOptions?

    /// A reference to a ``TabBarViewDestinationable`` object, should one currently exist in the UI hierarchy.
    public weak var tabBarDestination: (any TabBarViewDestinationable<DestinationPresentation, TabType>)?
       
    /// A reference to a ``TabBarControllerDestinationable`` object, should one currently exist in the UI hierarchy.
    public weak var tabBarControllerDestination: (any TabBarControllerDestinationable<DestinationPresentation, TabType>)?
    
    
    /// A Boolean which determines whether the activation of the presentation's completion closure, referenced in the ``completionClosure`` property, should be delayed. The default value of this property is `false`.
    public var shouldDelayCompletionActivation: Bool = false
    
    /// A Boolean which determines whether the Destination configured by this presentation should become the current one within the `Flowable` and `GroupedDestinationable` objects which manage it. Custom classes which conform to one of these protocols should handle this property appropriately. The default value of this property is `true`.
    ///
    /// The Destinations protocols and classes which handle UINavigationControllers/NavigationStacks and UITabController/TabBars ignore this property. Custom classes which conform to one of these protocols should handle this property appropriately, though generally speaking if a Destination is added to a `GroupedDestinationable` object, it would be a good user experience for that Destination to become the focus. This may vary based on how your custom group's children are displayed to the user.
    ///
    /// - Important: Setting this property to `false` can have side effects on the presentation of future Destinations within `GroupedDestinationable` objects whose placement depends on the location of a previous Destination. For example, if you present a Destination in a non-active child of a  `GroupedDestinationable` object with this property set to `false`, then present another Destination with a `presentationType` of `navigationController`, depending on how you handle this property the Destination may not be put into the same child of the group because the active child will be different than if this property had been `true`. To overcome this, you would need to use a `presentationType` on the second presentation that targets the same child directly.
    public var shouldSetDestinationAsCurrent: Bool = true
        
    /// A completion closure which should be run upon completion of the presentation of the Destination.
    public var completionClosure: ((Bool) -> Void)?
    
    /// Initializer.
    /// - Parameters:
    ///   - destinationType: The type of Destination to present.
    ///   - presentationType: The type of Destination presentation.
    ///   - contentType: The type of content.
    ///   - actionType: The type of presentation action.
    ///   - actionTargetID: The target identifier for the presentation action.
    ///   - assistantType: The type of assistant for the presentation.
    ///   - currentDestinationID: The identifier of the currently presented Destination.
    ///   - parentDestinationID: The identifier of the parent of the current Destination.
    ///   - navigator: The ``DestinationPathNavigating`` object associated with the Destination to be presented.
    ///   - shouldDelayCompletionActivation: Determines whether the activation of the presentation's completion closure, referenced in the ``completionClosure`` property, should be delayed.
    ///   - completionClosure: A completion closure which should be run upon completion of the presentation of the Destination.
    public init(destinationType: DestinationType? = nil, presentationType: PresentationType, contentType: ContentType? = nil, actionType: DestinationActionType = .presentation, actionTargetID: UUID? = nil, assistantType: ActionAssistantType, currentDestinationID: UUID? = nil, parentDestinationID: UUID? = nil, navigator: (any DestinationPathNavigating)? = nil, navigationStackOptions: NavigationStackPresentationOptions? = nil, shouldDelayCompletionActivation: Bool? = false, completionClosure: ( (Bool) -> Void)? = nil) {
        self.destinationType = destinationType
        self.presentationType = presentationType
        self.contentType = contentType
        self.actionType = actionType
        self.actionTargetID = actionTargetID
        self.assistantType = assistantType
        self.currentDestinationID = currentDestinationID
        self.parentDestinationID = parentDestinationID
        self.navigator = navigator
        self.navigationStackOptions = navigationStackOptions
        
        self.completionClosure = completionClosure
        
        if let shouldDelayCompletionActivation {
            self.shouldDelayCompletionActivation = shouldDelayCompletionActivation
        }
        
        if case .navigationController(type: .goBack) = presentationType {
            self.shouldDelayCompletionActivation = true
        }
    }
    
    
    public func copy() -> DestinationPresentation<DestinationType, ContentType, TabType> {
        return DestinationPresentation<DestinationType, ContentType, TabType>(
            destinationType: self.destinationType,
            presentationType: self.presentationType,
            contentType: self.contentType,
            actionType: self.actionType,
            actionTargetID: self.actionTargetID,
            assistantType: self.assistantType,
            currentDestinationID: self.currentDestinationID,
            parentDestinationID: self.parentDestinationID,
            navigator: self.navigator,
            navigationStackOptions: self.navigationStackOptions,
            shouldDelayCompletionActivation: self.shouldDelayCompletionActivation,
            completionClosure: self.completionClosure)
    }
    
#if canImport(SwiftUI)
    
    /// Handles the presentation of a SwiftUI-based Destination.
    /// - Parameters:
    ///   - destinationToPresent: The ``ViewDestinationable`` Destination to present.
    ///   - currentDestination: A ``ViewDestinationable`` object, representing the currently presented Destination.
    ///   - parentOfCurrentDestination: A ``ViewDestinationable`` object, representing the parent of the current Destination.
    ///   - removeDestinationClosure: An optional closure to the run when the Destination is removed from the UI hierarchy.
    @MainActor public func handlePresentation(destinationToPresent: (any ViewDestinationable<DestinationPresentation>)? = nil, currentDestination: (any ViewDestinationable<DestinationPresentation>)?, parentOfCurrentDestination: (any ViewDestinationable)?, removeDestinationClosure: RemoveDestinationClosure?)  {
        
        switch presentationType {
            case .navigationController(type: let navigationType):
                
                var navigationDestination: (any NavigatingViewDestinationable<DestinationPresentation>)?
                
                if let navDestination = currentDestination as? any NavigatingViewDestinationable<DestinationPresentation> {
                    navigationDestination = navDestination
                } else if let navDestination = parentOfCurrentDestination as? any NavigatingViewDestinationable<DestinationPresentation> {
                    navigationDestination = navDestination
                }
                
                if let navigationDestination {
                    switch navigationType {
                        case .present:
                            if let destinationToPresent {
                                navigationDestination.addChild(childDestination: destinationToPresent, shouldSetDestinationAsCurrent: shouldSetDestinationAsCurrent, shouldAnimate: navigationStackOptions?.shouldAnimate)
                                completionClosure?(true)
                            } else {
                                completionClosure?(false)
                            }
                        case .goBack:
                            navigationDestination.navigateBackInStack(previousPresentationID: id)
                    }
                    
                } else if let navigationDestination = destinationToPresent as? any NavigatingViewDestinationable<DestinationPresentation> {
                    switch navigationType {
                        case .present:
                            completionClosure?(false)
                        case .goBack:
                            navigationDestination.navigateBackInStack(previousPresentationID: id)
                    }

                } else {
                    completionClosure?(false)
                }

            case .tabBar(tab: let tab):

                if let tabBarDestination, let currentDestination {
                    do {
                        if let destinationToPresent {
                            try tabBarDestination.presentDestination(destination: destinationToPresent, in: tab, shouldUpdateSelectedTab: true, presentationOptions: navigationStackOptions)
                        } else {
                            // there's no specified Destination so we should just switch tabs
                            try tabBarDestination.updateSelectedTab(type: tab)
                        }
                        completionClosure?(true)
                    } catch {
                        DestinationsOptions.logger.log("\(error)")
                        completionClosure?(false)
                    }
                    
                } else {
                    completionClosure?(false)
                }
            
            case .addToCurrent:
                completionClosure?(false)
                
                
            case .replaceCurrent:
                if let currentDestination, let groupedDestination = parentOfCurrentDestination as? any GroupedDestinationable<DestinationPresentation> {
                    if let destinationToPresent {
                        groupedDestination.replaceChild(currentID: currentDestination.id, with: destinationToPresent)
                        removeDestinationClosure?(currentDestination.id)

                        completionClosure?(true)

                    } else {
                        completionClosure?(false)
                    }

                } else {
                    completionClosure?(true)
                }

            case .sheet(type: .present, options: let options):

                if let destinationToPresent, let view = destinationToPresent.currentView(), let currentDestination {
                    
                    let container = ContainerView {
                        AnyView(view)
                    }
                    
                    let sheet = Sheet(destinationID: destinationToPresent.id, view: container, options: options?.swiftUI)
                    currentDestination.presentSheet(sheet: sheet)
                    
                    completionClosure?(true)
                    
                } else {
                    completionClosure?(false)
                }
            case .sheet(type: .dismiss, options: let options):
                if let parentOfCurrentDestination {
                    parentOfCurrentDestination.dismissSheet()
                    completionClosure?(true)
                } else {
                    completionClosure?(false)
                }
                
            case .destinationPath(path: _):
                completionClosure?(true)
                
            case .custom(presentation: let presentation):
                guard let presentationClosure = presentation.swiftUI else {
                    completionClosure?(false)
                    return
                }
                presentationClosure(destinationToPresent, currentDestination, parentOfCurrentDestination, completionClosure)
        }
        
    }
#endif
    
#if canImport(UIKit)
    
    /// Handles the presentation of a UIKit-based Destination.
    /// - Parameters:
    ///   - destinationToPresent: The ``ControllerDestinationable`` Destination to present.
    ///   - rootController: A ``ControllerDestinationInterfacing`` object representing the root of the UI hierarchy.
    ///   - currentDestination: A ``ControllerDestinationable`` object, representing the currently presented Destination.
    ///   - parentOfCurrentDestination: A ``ControllerDestinationable`` object, representing the parent of the current Destination.
    ///   - removeDestinationClosure: An optional closure to the run when the Destination is removed from the UI hierarchy.
    public func handlePresentation(destinationToPresent: (any ControllerDestinationable<DestinationPresentation>)? = nil, rootController: (any ControllerDestinationInterfacing)? = nil, currentDestination: (any ControllerDestinationable)? = nil, parentOfCurrentDestination: (any ControllerDestinationable)? = nil, removeDestinationClosure: RemoveDestinationClosure? = nil) {
        
        switch presentationType {
        case .navigationController(type: let navigationType):
                
            switch navigationType {
                case .present:
                    if let destinationToPresent {
                        if let navController = currentDestination as? any NavigatingControllerDestinationable<DestinationPresentation> {
                            navController.addChild(childDestination: destinationToPresent, shouldSetDestinationAsCurrent: shouldSetDestinationAsCurrent, shouldAnimate: navigationStackOptions?.shouldAnimate)
                            completionClosure?(true)
                            
                        } else if let navController = currentDestination?.currentController()?.navigationController, let newController = destinationToPresent.currentController() {
                            if let navController = navController as? any NavigationControllerDestinationInterfacing, let navDestination = navController.destination() as? any NavigatingControllerDestinationable<DestinationPresentation> {
                                navDestination.addChild(childDestination: destinationToPresent, shouldSetDestinationAsCurrent: shouldSetDestinationAsCurrent, shouldAnimate: navigationStackOptions?.shouldAnimate)
                            } else {
                                let shouldAnimate = navigationStackOptions?.shouldAnimate ?? true
                                navController.pushViewController(newController, animated: shouldAnimate)
                            }
                            
                            completionClosure?(true)
                            
                        } else if let navController = rootController as? UINavigationController, let newController = destinationToPresent.currentController() {
                            let shouldAnimate = navigationStackOptions?.shouldAnimate ?? true
                            navController.pushViewController(newController, animated: shouldAnimate)
                            completionClosure?(true)
                            
                        } else {
                            completionClosure?(false)
                        }
                    } else {
                        completionClosure?(false)
                    }
                    
                case .goBack:
                    completionClosure?(true)
            }
            

            
        case .tabBar(let tab):
            if let tabBarControllerDestination, let currentDestination {
                    do {
                        if let destinationToPresent {
                            try tabBarControllerDestination.presentDestination(destination: destinationToPresent, in: tab, presentationOptions: navigationStackOptions)
                        } else {
                            // there's no specified Destination so we should just switch tabs
                            try tabBarControllerDestination.updateSelectedTab(type: tab)
                        }
                        completionClosure?(true)

                    } catch {
                        DestinationsOptions.logger.log("\(error)")
                        completionClosure?(false)
                    }

                
            } else {
                completionClosure?(false)
            }
                
        case .addToCurrent:
                if let currentDestination, let currentController = currentDestination.currentController(), let destinationToPresent, let newController = destinationToPresent.currentController() {
                    currentController.attach(viewController: newController)

                    destinationToPresent.parentDestinationID = currentDestination.id
                    
                    completionClosure?(true)
                } else {
                    completionClosure?(false)
                }
                
        case .replaceCurrent:
                guard let destinationToPresent, let rootController, let newController = destinationToPresent.currentController() else {
                    completionClosure?(false)
                    return
                }
                
                if let currentDestination, let groupedDestination = parentOfCurrentDestination as? any GroupedDestinationable<DestinationPresentation> {
                    let currentID = currentDestination.id
                    groupedDestination.replaceChild(currentID: currentID, with: destinationToPresent)
                    removeDestinationClosure?(currentID)
                    
                } else if let currentDestination, let currentController = currentDestination.currentController() {
                    let parent = currentController.parent

                    if let navController = parent as? UINavigationController {
                        navController.replaceLastController(with: newController)

                    } else {
                        currentController.removeFromParent()
                        parent?.attach(viewController: newController)
                        removeDestinationClosure?(currentDestination.id)
                    }
                    
                } else {
                    rootController.attach(viewController: newController)
                }
                
                completionClosure?(true)
               
        case .sheet(type: .present, options: let options):
            guard let destinationToPresent, let presentingController = currentDestination?.currentController(), let sheetController = destinationToPresent.currentController() else {
                completionClosure?(false)
                return
            }
                            
            if let options = options?.uiKit {
                if let configurationClosure = options.configurationClosure, let presentationController = sheetController.sheetPresentationController {
                    configurationClosure(presentationController)
                }
                if let presentationStyle = options.presentationStyle {
                    sheetController.modalPresentationStyle = presentationStyle
                }
                if let transitionStyle = options.transitionStyle {
                    sheetController.modalTransitionStyle = transitionStyle
                }
                sheetController.transitioningDelegate = options.transitionDelegate

            }
            
            let isAnimated: Bool = options?.uiKit?.isAnimated ?? true
            
            presentingController.present(sheetController, animated: isAnimated) {
                self.completionClosure?(true)
            }
                
        case .sheet(type: .dismiss, options: let options):

            guard let currentController = currentDestination?.currentController() else {
                completionClosure?(false)
                return
            }

            let options = options?.uiKit

            if let presentationStyle = options?.presentationStyle {
                currentController.modalPresentationStyle = presentationStyle
            }
            if let transitionStyle = options?.transitionStyle {
                currentController.modalTransitionStyle = transitionStyle
            }
            currentController.transitioningDelegate = options?.transitionDelegate

            let isAnimated: Bool = options?.isAnimated ?? true
            currentController.dismiss(animated: isAnimated) {
                self.completionClosure?(true)
            }
                
                
        case .destinationPath(path: _):
            completionClosure?(true)
                
        case .custom(presentation: let presentation):
            guard let presentationClosure = presentation.uiKit else {
                completionClosure?(false)
                return
            }
            presentationClosure(destinationToPresent, rootController, currentDestination, parentOfCurrentDestination, completionClosure)

        }
        
    }
#endif
    
}

extension DestinationPresentation: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: DestinationPresentation, rhs: DestinationPresentation) -> Bool {
        return (lhs.id == rhs.id)
    }
}
