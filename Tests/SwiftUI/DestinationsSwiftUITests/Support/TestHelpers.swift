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
    case splitView

}

@MainActor final class TestHelpers {
    typealias UserInteractionType = GeneralAppInteractions
    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias ContentType = AppContentType
    
    static func buildAppFlow(startingDestination: DestinationPresentation<DestinationType, ContentType, TabType>, startingTabs: [AppTabType]? = nil, splitViewContent: [NavigationSplitViewColumn: RouteDestinationType]? = nil) -> ViewFlow<DestinationType, TabType, ContentType> {
        
        let splitViewColumns = splitViewContent ?? [.sidebar: .colorsList, .detail: .colorDetail]
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        let sheetPresent = PresentationConfiguration(destinationType: .colorsList, presentationType: .sheet(type: .present), assistantType: .basic)
             
        let colorsListRetrieveAction = InteractorConfiguration<ColorsListDestination.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .retrieve, assistantType: .custom(ColorsInteractorAssistant(actionType: .retrieve)))
        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection], interactorsData: [.retrieveInitialColors: colorsListRetrieveAction])
        
        let colorDetailProvider = ColorDetailProvider()
        let homeProvider = HomeProvider(presentationsData: [.pathPresent: sheetPresent])
        let tabBarProvider = TabBarProvider()
        let splitViewProvider = SplitViewProvider(initialContent: splitViewColumns)

        let tabs = startingTabs ?? [.palettes, .home]
        
        var providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider,
            .splitView: splitViewProvider,
            .tabBar(tabs: tabs): tabBarProvider
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

    var requestResponses: [Request.ActionType: InteractorResponseClosure<Request>] = [:]

    var counter: Int = 0
    
    func perform(request: Request) {
        
        switch request.action {
            case .increaseCount:
                counter += 1
                
                let response = responseForAction(action: request.action)
                response?(.success(.counter(count: counter)), request)
                
        }
    }
}

struct TestRequest: InteractorRequestConfiguring {
  
    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType
    typealias Item = Int

    var action: TestInteractorOptions.ActionType
}

struct TestInteractorOptions: InteractorRequestConfiguring {
        
    enum ActionType: InteractorRequestActionTypeable {
        case increaseCount
    }
    
    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType
    typealias Item = Int

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
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias Destination = ViewDestination<TestGroupView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    typealias ViewType = TestGroupView
    
    let id: UUID = UUID()
    
    var type: TestDestinationType = .group
    var view: TestGroupView?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()
    

    func prepareForPresentation() {
    }
}


final class TestNavigatorDestination<ViewType: NavigatingDestinationInterfacing>: NavigatingViewDestinationable, DestinationTypes {
    
    enum UserInteractions: String, UserInteractionTypeable {
        case test
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias Destination = ViewDestination<TestGroupView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    
    let id: UUID = UUID()

    var type: TestDestinationType = .group
    var view: ViewType?

    public var internalState: DestinationInternalState<UserInteractionType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

}

struct TestGroupView: NavigatingDestinationInterfacing, DestinationTypes {

    typealias UserInteractionType = TestGroupDestination.UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = TestNavigatorDestination<Self>
    
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>
           
    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
    }

    var body: some View {
        NavigationStack(path: $destinationState.navigator.navigationPath, root: {
            VStack {
                Button("Test") {
                    try? destination().performInterfaceAction(interactionType: .test)
                }
            }
        })
    }

}


struct TestGroupContainerView<Content: View>: NavigatingDestinationInterfacing, DestinationTypes {

    typealias UserInteractionType = TestGroupDestination.UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = TestNavigatorDestination<Self>
    
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>
           
    @State public var content: Content?

    init(destination: Destination, content: (() -> Content)? = nil) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
        if let content {
            self.content = content()
        }
    }

    var body: some View {
        NavigationStack(path: $destinationState.navigator.navigationPath, root: {
            VStack {
                content
            }
        })
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
    typealias Destination = ViewDestination<TestView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>
            
    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
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
    typealias Destination = TabViewDestination<Self, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
        
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>


    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
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

struct TestSplitView: NavigationSplitViewDestinationInterfacing, DestinationTypes {
    
    enum UserInteractions: UserInteractionTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias Destination = NavigationSplitViewDestination<Self, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
        
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
            
    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                BindableContainerView(content: $destinationState.destination.currentSidebar)
            } content: {
                BindableContainerView(content: $destinationState.destination.currentContent)
            } detail: {
                BindableContainerView(content: $destinationState.destination.currentDetail)

            }

        }
    }
    
}

