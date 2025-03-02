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
        case retrieveInitialColors
        case moreButton
        
        var rawValue: String {
            switch self {
                case .color:
                    return "color"
                case .retrieveInitialColors:
                    return "retrieveInitialColors"
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

    public var internalState: DestinationInternalState<InteractorType, UserInteractionType, PresentationType, PresentationConfiguration> = DestinationInternalState()
    public var groupInternalState: GroupDestinationInternalState<PresentationType, PresentationConfiguration> = GroupDestinationInternalState()
    
    var items: [ColorViewModel] = []

    private(set) var listID: UUID = UUID()

    private(set) var cancellables: Set<AnyCancellable> = []

    init(destinationConfigurations: DestinationConfigurations? = nil, navigationConfigurations: NavigationConfigurations? = nil, parentDestination: UUID? = nil) {
        self.internalState.parentDestinationID = parentDestination
        self.internalState.destinationConfigurations = destinationConfigurations
        self.internalState.systemNavigationConfigurations = navigationConfigurations
    }
    
    func configureInteractor(_ interactor: any AbstractInteractable, type: ColorsListDestination.InteractorType) {
        switch type {
            case .colors:
                if let datasource = interactor as? ColorsDatasource {
                    subscribeToDatasource(datasource: datasource)
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
            DestinationsSupport.logger.log("items received \(items)", category: .network)
        })
        .store(in: &cancellables)
    }

    func prepareForPresentation() {
        // retrieve initial colors
        handleThrowable(closure: {
            try self.performInterfaceAction(interactionType: .retrieveInitialColors)
        })
    }
}
