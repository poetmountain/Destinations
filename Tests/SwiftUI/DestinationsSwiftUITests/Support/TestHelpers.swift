//
//  TestHelpers.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import XCTest

@testable import DestinationsSwiftUI
import Destinations

extension XCTestCase {

  func wait(timeout: TimeInterval) {
    let expectation = XCTestExpectation(description: "Waiting for \(timeout) seconds")
    XCTWaiter().wait(for: [expectation], timeout: timeout)
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

@MainActor final class TestHelpers {
    typealias UserInteractionType = GeneralAppInteractions
    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    typealias ContentType = AppContentType
    
    static func buildAppFlow(startingDestination: PresentationConfiguration, startingTabs: [AppTabType]? = nil) -> ViewFlow<DestinationType, TabType, ContentType> {
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .basic)
        let sheetPresent = PresentationConfiguration(destinationType: .colorsList, presentationType: .sheet(type: .present), assistantType: .basic)
                
        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        let colorDetailProvider = ColorDetailProvider(presentationsData: [:])
        let homeProvider = HomeProvider(presentationsData: [.pathPresent: sheetPresent])
        let tabBarProvider = TabBarProvider()

        var providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider
        ]
        
        if let startingTabs {
            providers[.tabBar(tabs: startingTabs)] = tabBarProvider
        }

        return ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
    }

    
}

protocol DestinationTypeable {
    @MainActor var type: RouteDestinationType { get }
}

extension ColorsListDestination: DestinationTypeable {}
extension ColorDetailDestination: DestinationTypeable {}

extension ColorsListView {
    
    func selectCell(id: UUID) {
        
        self.selectedItem = id
        //RunLoop.current.run(until: Date())
    }
    
    func numberOfCells() -> Int {
        return self.destination().items.count
    }
    
    func model(for itemID: UUID) -> ColorViewModel? {
        return self.destination().items.first(where: { $0.id == itemID })
    }
    
}

final class TestInteractor: Interactable {

    typealias Request = TestRequest
    typealias ResultData = Request.ResultData
    
    var counter: Int = 0
    
    func perform(request: Request, completionClosure: DatasourceResponseClosure<[ResultData]>?) {
        
        switch request.action {
            case .increaseCount:
                counter += 1
                completionClosure?(.success([counter]))
        }
    }
}

struct TestRequest: InteractorRequestConfiguring {
  
    typealias ResultData = Int

    var action: TestInteractorOptions.ActionType
}

struct TestInteractorOptions: InteractorRequestConfiguring {
        
    enum ActionType: InteractorRequestActionTypeable {
        case increaseCount
    }
    
    typealias RequestType = ActionType
    typealias ResultData = Int
    
    var action: ActionType

    
}

final class TestGroupDestination: ViewDestinationable, GroupedDestinationable, DestinationTypes {
    
        
    enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    typealias Destination = ViewDestination<UserInteractionType, TestGroupView, PresentationConfiguration>
    typealias ViewType = TestGroupView
    
    var type: TestDestinationType = .group
    
    var parentDestinationID: UUID?
    
    var destinationConfigurations: DestinationConfigurations?
    
    var systemNavigationConfigurations: NavigationConfigurations?
    
    var supportsIgnoringCurrentDestinationStatus: Bool = false

    var isSystemNavigating: Bool = false
    
    var interactors: [AppInteractorType : any Interactable] = [:]
    
    var interfaceActions: [UserInteractions : InterfaceAction<UserInteractions, TestDestinationType, AppContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, TestDestinationType, DestinationsSwiftUI.AppContentType>] = [:]
    var interactorAssistants: [UserInteractions : any InteractorAssisting<TestGroupDestination>] = [:]

    var childWasRemovedClosure: Destinations.GroupChildRemovedClosure?
    var currentDestinationChangedClosure: Destinations.GroupCurrentDestinationChangedClosure?
    
    var view: TestGroupView?

    var childDestinations: [any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>] = []
    var currentChildDestination: (any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>)?
    
    let id: UUID = UUID()
    
}


final class TestNavigatorDestination: NavigatingViewDestinationable, DestinationTypes {
    
    enum UserInteractions: String, UserInteractionTypeable {
        case test
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<PresentationConfiguration>
    typealias Destination = ViewDestination<UserInteractionType, TestGroupView, PresentationConfiguration>
    typealias ViewType = TestGroupView
    
    var type: TestDestinationType = .group
    
    var parentDestinationID: UUID?
    
    var destinationConfigurations: DestinationConfigurations?
    
    var systemNavigationConfigurations: NavigationConfigurations?
    
    var isSystemNavigating: Bool = false
    
    var interactors: [AppInteractorType : any Interactable] = [:]
    
    var interfaceActions: [UserInteractions : InterfaceAction<UserInteractions, TestDestinationType, AppContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, TestDestinationType, DestinationsSwiftUI.AppContentType>] = [:]
    var interactorAssistants: [UserInteractions : any InteractorAssisting<TestNavigatorDestination>] = [:]

    var childWasRemovedClosure: Destinations.GroupChildRemovedClosure?
    var currentDestinationChangedClosure: Destinations.GroupCurrentDestinationChangedClosure?
    
    var view: TestGroupView?

    var childDestinations: [any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>] = []
    var currentChildDestination: (any Destinationable<DestinationPresentation<DestinationType, AppContentType, TabType>>)?
    
    let id: UUID = UUID()
    
}

struct TestGroupView: NavigatingDestinationInterfacing, DestinationTypes {

    typealias UserInteractionType = TestGroupDestination.UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = TestNavigatorDestination
    
    @State var navigator: any DestinationPathNavigating = DestinationNavigator()

    @State public var destinationState: DestinationInterfaceState<Destination>
            
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack {
            Button("Test") {
                try? destination().performInterfaceAction(interactionType: .test)
            }
        }
    }

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

struct TestView: ViewDestinationInterfacing, DestinationTypes {
    
    enum UserInteractions: String, UserInteractionTypeable {
        case test
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = ViewDestination<UserInteractionType, TestView, PresentationConfiguration>
    
    @State public var destinationState: DestinationInterfaceState<Destination>
            
    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack {
            Button("Test") {
                try? destination().performInterfaceAction(interactionType: UserInteractions.test)
            }
        }
    }

}

struct TestTabView: TabBarViewDestinationInterfacing, DestinationTypes {
        
    enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<TestDestinationType, AppContentType, TabType>
    typealias Destination = TabViewDestination<PresentationConfiguration, Self>
        
    @State public var destinationState: DestinationInterfaceState<Destination>


    init(destination: Destination) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $destinationState.destination.selectedTab) {
                ForEach($destinationState.destination.activeTabs, id: \.self) { tab in
                    buildView(for: tab.wrappedValue)
                        .tag(tab.wrappedValue.type.tabName)
                        .tabItem {
                            Label(tab.wrappedValue.type.tabName, systemImage: "house")
                        }
                }

            }
            
        }
    }
    
    
    @ViewBuilder func buildView(for tab: TabModel<TabType>) -> (some View)? {

        if let view = destination().currentDestination(for: tab.type)?.currentView() {
            AnyView(view)
        }

    }

}

