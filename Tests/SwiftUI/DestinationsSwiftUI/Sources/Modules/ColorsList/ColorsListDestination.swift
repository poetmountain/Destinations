//
//  ColorsListDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations
import Combine

@Observable
final class ColorsListDestination: DestinationTypes, NavigatingViewDestinationable {
    
    typealias ViewType = ColorsListView
    typealias UserInteractionType = UserInteractions

    enum UserInteractions: UserInteractionTypeable {
        case color(model: ColorViewModel?)
        case moreButton
        
        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .moreButton:
                    return "moreButton"
            }
        }
        
        static func == (lhs: UserInteractions, rhs: UserInteractions) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    enum InteractorType: InteractorTypeable {
        case colors
    }
        
    public let id = UUID()
    
    public let type: RouteDestinationType = .colorsList
    
    public var view: ViewType?

    var childDestinations: [any Destinationable<PresentationConfiguration>] = []
    var currentChildDestination: (any Destinationable<PresentationConfiguration>)?
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    public var systemNavigationConfigurations: NavigationConfigurations?
    
    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractions : any InteractorAssisting<ColorsListDestination>] = [:]

    public var childWasRemovedClosure: GroupChildRemovedClosure?
    public var currentDestinationChangedClosure: GroupCurrentDestinationChangedClosure?

    var items: [ColorViewModel] = []

    private(set) var listID: UUID = UUID()

    public var isSystemNavigating: Bool = false

    private(set) var cancellables: Set<AnyCancellable> = []

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }
    
    func configureInteractor(_ interactor: any Interactable, type: ColorsListDestination.InteractorType) {
        switch type {
            case .colors:
                if let datasource = interactor as? ColorsDatasource {
                    subscribeToDatasource(datasource: datasource)
                    datasource.startItemsRetrieval()
                }
        }
    }
    
    func subscribeToDatasource(datasource: ColorsDatasource) {
        cancellables.removeAll()
                
        // set up Combine subscriber for the items provider
        datasource.itemsProvider
        .receive(on: RunLoop.main)
        .compactMap { $0 }
        .sink(receiveValue: { [weak self] (current) in
            guard let strongSelf = self else { return }
            let items = current
            strongSelf.items = items
            DestinationsOptions.logger.log("items received \(items)", category: .network)
        })
        .store(in: &cancellables)
    }

}
