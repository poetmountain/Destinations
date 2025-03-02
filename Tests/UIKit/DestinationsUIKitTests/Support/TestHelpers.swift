//
//  TestHelpers.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Combine
import XCTest

@testable import DestinationsUIKit
import Destinations


@MainActor final class TestDestinations: DestinationTypes {
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    
    var appFlow: ControllerFlow<DestinationType, TabType, ContentType>?
    
    func buildAppFlow(startingDestination: PresentationConfiguration, navigationController: UIViewController? = nil, startingTabs: [AppTabType]? = nil) -> ControllerFlow<DestinationType, TabType, ContentType> {

        let startingTabs: [AppTabType] = startingTabs ?? [.palettes, .home]
        
        
        let homepath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), contentType: .color(model: ColorViewModel(color: .orange, name: "orange")), assistantType: .basic)
        ]
        
        let replaceColor = PresentationConfiguration(destinationType: .colorDetail, presentationType: .replaceCurrent, contentType: .color(model: ColorViewModel(colorID: UUID(), color: .yellow, name: "yellow")), assistantType: .basic)


        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .custom(TestChooseColorFromListActionAssistant()))

        let homePathPresent = PresentationConfiguration(presentationType: .destinationPath(path: homepath), assistantType: .basic)
        let sheetPresent = PresentationConfiguration(destinationType: .sheet, presentationType: .sheet(type: .present), assistantType: .custom(ColorDetailActionAssistant()))
        
        let startProvider = StartProvider()
        
        let colorsListRetrieveAction = InteractorConfiguration<TestColorsDestination.InteractorType, TestColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(TestColorsInteractorAssistant(actionType: .retrieve)))
        
        let colorsListMoreButtonAction = InteractorConfiguration<TestColorsDestination.InteractorType, TestColorsDatasource>(interactorType: .colors, actionType: .paginate, assistantType: .custom(TestColorsInteractorAssistant(actionType: .paginate)))
        
        let colorsListProvider = TestColorsListProvider(presentationsData: [.color(model: nil): colorSelection], interactorsData: [.moreButton: colorsListMoreButtonAction, .retrieveInitialColors: colorsListRetrieveAction])
        
        let colorDetailProvider = ColorDetailProvider(presentationsData: [.colorDetailButton(model: nil): sheetPresent])
        let homeProvider = HomeProvider(presentationsData: [.pathPresent: homePathPresent, .replaceView: replaceColor])
        let tabBarProvider = TabBarProvider()

        let providers: [RouteDestinationType: any ControllerDestinationProviding] = [
            .start: startProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider,
            .tabBar(tabs: startingTabs): tabBarProvider
        ]
        
        let flow = ControllerFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
        if let rootController = navigationController as? any ControllerDestinationInterfacing {
            flow.assignRoot(rootController: rootController)
        }
        return flow
    }
    
    func systemNavigationConfigurations() -> [SystemNavigationType: PresentationConfiguration] {
        let goBackAction = PresentationConfiguration(presentationType: .navigationStack(type: .goBack), actionType: .systemNavigation, assistantType: .basic)
        let sheetDismiss = PresentationConfiguration(presentationType: .sheet(type: .dismiss), actionType: .systemNavigation, assistantType: .basic)

        return [.navigateBackInStack: goBackAction, .dismissSheet: sheetDismiss]
    }
}



final class TestTabBarProvider: ControllerDestinationProviding, DestinationTypes {
    public typealias Destination = TabBarControllerDestination<PresentationConfiguration, AppTabBarController>
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init(presentationsData: [Destination.UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [Destination.UserInteractionType: any InteractorConfiguring<Destination.InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
        
        guard let destinationType = configuration.destinationType else { return nil }
        guard case let RouteDestinationType.tabBar(tabs: tabs) = destinationType else { return nil }
        
        var tabTypes: [TabType] = []
        var tabDestinations: [any ControllerDestinationable<PresentationConfiguration>] = []
        
        // create starting content for each tab
        for tabType in tabs {
            let tabContentType: RouteDestinationType
            switch tabType {
                case .palettes:
                    tabContentType = .colorsList
                case .home:
                    tabContentType = .home
            }
            let tabConfig = configuration
            tabConfig.destinationType = tabContentType
            
            
            
            if let destination = appFlow.buildDestination(for: tabConfig) {
                tabTypes.append(tabType)
                tabDestinations.append(destination)
            }
        }
                
        if let destination = TabBarControllerDestination<PresentationConfiguration, AppTabBarController>(type: .tabBar(tabs: tabTypes), tabDestinations: tabDestinations, tabTypes: tabTypes, selectedTab: .palettes, navigationConfigurations: navigationPresentations) {
            
            let tabController = AppTabBarController(destination: destination)
            destination.assignAssociatedController(controller: tabController)
            
            for tabDestination in tabDestinations {
                tabDestination.setParentID(id: destination.id)
            }
            
            return destination
        } else {
            return nil
        }
        
    }
}



final class TestColorsListProvider: ControllerDestinationProviding, DestinationTypes  {

    public typealias Destination = TestColorsDestination
    public typealias PresentationConfiguration = DestinationPresentation<DestinationType, ContentType, TabType>

    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractions : any InteractorConfiguring<Destination.InteractorType>] = [:]

    init(presentationsData: [Destination.UserInteractionType: PresentationConfiguration]? = nil, interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>]? = nil) {
        if let presentationsData {
            self.presentationsData = presentationsData
        }
        if let interactorsData {
            self.interactorsData = interactorsData
        }
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, PresentationConfiguration>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationPresentation<DestinationType, ContentType, TabType>>?, configuration: PresentationConfiguration, appFlow: some ControllerFlowable<PresentationConfiguration>) -> Destination? {
        
        let destination = TestColorsDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let controller = TestColorsViewController(destination: destination)
        destination.assignAssociatedController(controller: controller)

        let datasource = TestColorsDatasource(with: ColorsPresenter())
        destination.assignInteractor(interactor: datasource, for: .colors)

         return destination
        
    }
    
}


final class TestColorsDatasource: Datasourceable {

    typealias Request = ColorsRequest
    typealias Item = Request.Item
    
    var requestResponses: [Request.ActionType : InteractorResponseClosure<ColorsRequest>] = [:]

    @Published var items: [Item] = []

    var itemsProvider: Published<[Request.Item]>.Publisher { $items }

    let presenter: ColorsPresenting
    
    init(with presenter: ColorsPresenting) {
        self.presenter = presenter
    }
    
    func prepareForRequests() {
        perform(request: ColorsRequest(action: .retrieve))
    }

    func perform(request: Request) {
        
        switch request.action {
            case .retrieve, .paginate:
                retrieveColors(request: request)
                
        }

    }
    
    func retrieveColors(request: Request) {
        
        let red = ColorModel(color: UIColor.red, name: "red")
        let yellow = ColorModel(color: UIColor.yellow, name: "yellow")
        let blue = ColorModel(color: UIColor.blue, name: "blue")
        let orange = ColorModel(color: UIColor.orange, name: "orange")
        let pink = ColorModel(color: UIColor.systemPink, name: "pink")
        let allColors = [red, yellow, blue, orange, pink]
        
        let range: Range<Int> = 0..<request.numColorsToRetrieve
        let colors = Array(allColors[safe: range])
                
        let response = responseForAction(action: request.action)
        
        
        let result = presenter.present(colors: colors, response: response, request: request)
        switch result {
            case .success(let response):
                switch response {
                    case .colors(models: let models):
                        self.items = models
                    default: break
                }
            case .failure(_):
                break
        }

    }
    
}


public enum TestDestinationType: String, RoutableDestinations {
    
    public var id: String { rawValue }
    
    case home
    case list
    case detail
    case replacement
    case group
    case tabBar
 
}

public enum TestTabType: String, TabTypeable {
 
    case group
    case home
    
    
    public var tabName: String {
        switch self {
            case .group:
                return "Group"
            case .home:
                return "Home"
        }
    }

}


final class TestGroupDestination: ControllerDestinationable, GroupedDestinationable, DestinationTypes {
    
        
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    typealias ControllerType = TestGroupViewController
    
    let id: UUID = UUID()

    var type: TestDestinationType = .group
    
    var controller: TestGroupViewController?

    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<PresentationType, PresentationConfiguration> = GroupDestinationInternalState()
    
    func prepareForPresentation() {
    }
}


final class TestViewController: UIViewController, ControllerDestinationInterfacing, DestinationTypes {
    
    enum Selections: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = Selections
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = TestGroupDestination.PresentationConfiguration
    typealias Destination = ControllerDestination<UserInteractionType, TestViewController, PresentationConfiguration, InteractorType>
    typealias TabType = TestTabType

    var destinationState: DestinationInterfaceState<Destination>

    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class TestGroupViewController: UINavigationController, NavigationControllerDestinationInterfacing, DestinationTypes {
    
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias InteractorType = AppInteractorType
    typealias PresentationConfiguration = TestGroupDestination.PresentationConfiguration
    typealias Destination = TestGroupDestination
    typealias TabType = TestTabType

    var destinationState: DestinationInterfaceState<Destination>

    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



final class TestTabBarController: UITabBarController, TabBarControllerDestinationInterfacing, DestinationTypes {
    
    enum UserInteractions: UserInteractionTypeable {
        var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<TestDestinationType, AppContentType, TabType>
    typealias Destination = TabBarControllerDestination<PresentationConfiguration, TestTabBarController>

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

final class TestChooseColorFromListActionAssistant: InterfaceActionConfiguring, DestinationTypes {
    typealias UserInteractionType = TestColorsDestination.UserInteractions
    
    func configure(interfaceAction: InterfaceAction<UserInteractionType, DestinationType, ContentType>, interactionType: UserInteractionType, destination: any Destinationable, content: ContentType?) -> InterfaceAction<UserInteractionType, DestinationType, ContentType> {
        var closure = interfaceAction
        
        var routeType: RouteDestinationType?
        var contentType: ContentType?
        
        closure.data.parentID = destination.parentDestinationID()
        
        switch interactionType {
            case .color(model: let model):
                routeType = RouteDestinationType.colorDetail
                
                if let model {
                    contentType = .color(model: model)
                }
                
                closure.data.contentType = contentType
                closure.data.parentID = destination.id
                
            case .moreButton, .retrieveInitialColors:
                break
        }
        
        
        if let contentType {
            closure.data.contentType = contentType
        }
        
        if let routeType {
            closure.data.destinationType = routeType
        }
        
        
        return closure
    }
}



struct TestError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}


protocol DestinationTypeable {
    typealias DestinationType = RouteDestinationType
}

extension TestColorsDestination: DestinationTypeable {}
extension ControllerDestination: DestinationTypeable {}
extension ColorDetailDestination: DestinationTypeable {}
extension NavigationControllerDestination: DestinationTypeable {}
extension TabBarControllerDestination: DestinationTypeable {}

extension UIViewController {
    ///
    /// This test helper extension provides a fast and reliable way of
    /// triggering lifecycle events programatically (viewDidLoad, viewWillAppear, and viewDidAppear)
    /// to ensure the view controller is ready for testing.
    ///
    /// It replaces the UIRefreshControl with a Spy to support testing on iOS17+.
    ///
    func prepareForFirstAppearance() {
        guard !isViewLoaded else { return }
        
        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}

extension XCTestCase {

    @MainActor var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    @MainActor var sceneDelegate: SceneDelegate? {
        return UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }


    func wait(timeout: TimeInterval) {
        let expectation = XCTestExpectation(description: "Waiting for \(timeout) seconds")
        XCTWaiter().wait(for: [expectation], timeout: timeout)
    }

}


