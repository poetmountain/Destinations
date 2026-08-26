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
    typealias EventType = GeneralAppEvents
    typealias InteractorType = AppInteractorType
    typealias DestinationType = RouteDestinationType
    typealias TabType = AppTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias ContentType = AppContentType
    
    static func buildAppFlow(startingDestination: DestinationPresentation<DestinationType, ContentType, TabType>, startingTabs: [AppTabType]? = nil, splitViewContent: [NavigationSplitViewColumn: RouteDestinationType]? = nil) -> ViewFlow<DestinationType, TabType, ContentType> {
        
        DestinationsSupport.logger.options.maximumOutputLevel = .error
        
        let splitViewColumns = splitViewContent ?? [.sidebar: .colorsList, .detail: .colorDetail]
        
        let sheetPresent = PresentationConfiguration(destinationType: .colorsList, presentationType: .sheet(type: .present), assistantType: .basic)
             
        let colorsListProvider = ColorsListProvider()
        
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

extension ColorsListView.Destination: DestinationTypeable {}
extension ColorDetailView.Destination: DestinationTypeable {}

extension ColorsListView {

    func selectCell(id: UUID) {
        self.stateModel.selectedItem = id
        //RunLoop.current.run(until: Date())
    }

    func numberOfCells() -> Int {
        return self.stateModel.items.count
    }

    func model(for itemID: UUID) -> ColorViewModel? {
        return self.stateModel.items.first(where: { $0.id == itemID })
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

/// A test assistant which implements both `handleAsyncRequest` and `asyncRequest`, allowing us to verify the new async `performAction` and `asyncRequest` flows on `Destinationable` and `AsyncInteractorAssisting`.
struct TestAsyncColorsInteractorAssistant: AsyncInteractorAssisting, DestinationTypes {

    typealias InteractorType = ColorsListView.InteractorType
    typealias Request = ColorsRequest

    let interactorType: InteractorType = .colors

    func handleAsyncRequest<Destination: Destinationable>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async where Destination.InteractorType == InteractorType {
        let request = ColorsRequest(action: actionType)
        let result = await destination.performRequest(interactor: interactorType, request: request)
        await destination.handleAsyncInteractorResult(result: result, for: request)
    }

    func asyncRequest<Destination: InteractorResultHandling>(destination: Destination, actionType: Request.ActionType, content: ContentType?) async -> Result<Request.ResultData, Error> where Destination.InteractorType == InteractorType {
        let request = ColorsRequest(action: actionType)
        return await destination.performRequest(interactor: interactorType, request: request)
    }
}

final class TestGroupDestination: ViewDestinationable, GroupedDestinationable, DestinationTypes {
    
    enum Events: EventTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias EventType = Events
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias Destination = ViewDestination<TestGroupView, EventType, DestinationType, ContentType, TabType, InteractorType>
    typealias ViewType = TestGroupView
    
    let id: UUID = UUID()
    
    var type: TestDestinationType = .group
    var view: TestGroupView?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()
    
}


final class TestNavigatorDestination<ViewType: NavigatingDestinationInterfacing>: NavigatingViewDestinationable, DestinationTypes {
    
    enum Events: String, EventTypeable {
        case test
    }
    
    typealias EventType = Events
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias PresentationType = DestinationPresentationType<DestinationType, ContentType, TabType>
    typealias Destination = ViewDestination<TestGroupView, EventType, DestinationType, ContentType, TabType, InteractorType>
    
    let id: UUID = UUID()

    var type: TestDestinationType = .group
    var view: ViewType?

    public var internalState: DestinationInternalState<EventType, DestinationType, ContentType, TabType, InteractorType> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<DestinationType, ContentType, TabType> = GroupDestinationInternalState()

}

struct TestGroupView: NavigatingDestinationInterfacing, DestinationTypes {

    typealias EventType = TestGroupDestination.Events
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
                    try? destination().performAction(for: .test)
                }
            }
        })
    }

}


struct TestGroupContainerView<Content: View>: NavigatingDestinationInterfacing, DestinationTypes {

    typealias EventType = TestGroupDestination.Events
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
    
    enum Events: String, EventTypeable {
        case test
    }
    
    typealias EventType = Events
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias Destination = ViewDestination<TestView, EventType, DestinationType, ContentType, TabType, InteractorType>
    
    @State public var destinationState: NavigationDestinationInterfaceState<Destination>
            
    init(destination: Destination) {
        self.destinationState = NavigationDestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack {
            Button("Test") {
                try? destination().performAction(for: Events.test)
            }
        }
    }

}

struct TestTabView: TabBarViewDestinationInterfacing, DestinationTypes {
        
    enum Events: EventTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias EventType = Events
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias PresentationConfiguration = DestinationPresentation<TestDestinationType, AppContentType, TabType>
    typealias Destination = TabViewDestination<Self, EventType, DestinationType, ContentType, TabType, InteractorType>
        
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
    
    enum Events: EventTypeable {
        public var rawValue: String {
            return ""
        }
    }
    
    typealias EventType = Events
    typealias DestinationType = TestDestinationType
    typealias InteractorType = AppInteractorType
    typealias TabType = TestTabType
    typealias Destination = NavigationSplitViewDestination<Self, EventType, DestinationType, ContentType, TabType, InteractorType>
        
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

/// A datasource whose requests suspend until `openGate()` is called, allowing tests to deterministically
/// cancel a sequence while one of its interactor requests is in progress. The gate deliberately ignores
/// task cancellation so that the request always completes successfully, ensuring it is the sequence's own
/// cancellation handling that fails the sequence rather than an error from the interactor.
actor GatedColorsDatasource: AsyncInteractable {

    typealias Request = ColorsRequest

    var items: [ColorViewModel] = []

    private var hasStarted = false
    private var startContinuation: CheckedContinuation<Void, Never>?
    private var gateContinuation: CheckedContinuation<Void, Never>?

    /// Suspends until this datasource has begun performing a request.
    func waitUntilRequestStarts() async {
        if hasStarted { return }
        await withCheckedContinuation { continuation in
            startContinuation = continuation
        }
    }

    /// Allows an in-progress request to complete.
    func openGate() {
        gateContinuation?.resume()
        gateContinuation = nil
    }

    func perform(request: Request) async -> Result<ColorsRequest.ResultData, Error> {
        hasStarted = true
        startContinuation?.resume()
        startContinuation = nil

        await withCheckedContinuation { continuation in
            gateContinuation = continuation
        }

        return .success(.colors(models: [ColorViewModel(colorID: UUID(), color: .red, name: "red")]))
    }
}
