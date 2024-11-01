//
//  TestColorsDestination.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations
@testable import DestinationsUIKit

@Observable
final class TestColorsDestination: DestinationTypes, ControllerDestinationable {
    
    enum UserInteractions: UserInteractionTypeable {
        case color(model: ColorViewModel?)
        
        var rawValue: String {
            switch self {
                case .color(_):
                    return "color"
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
        
        var rawValue: String {
            switch self {
                case .colors:
                    return "colors"
            }
        }
        
        static func == (lhs: InteractorType, rhs: InteractorType) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias UserInteractionType = UserInteractions
    typealias DestinationConfigurations = AppDestinationConfigurations<UserInteractionType, DestinationPresentation<DestinationType, AppContentType, TabType>>
    typealias ControllerType = TestColorsViewController
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    
    public let id = UUID()
    
    public let type: RouteDestinationType = .colorsList
    
    public var controller: ControllerType?
    
    public var parentDestinationID: UUID?
    
    public var destinationConfigurations: DestinationConfigurations?
    var systemNavigationConfigurations: NavigationConfigurations?

    public var isSystemNavigating: Bool = false
    
    var interactors: [InteractorType : any Interactable] = [:]
    var interfaceActions: [UserInteractionType: InterfaceAction<UserInteractionType, DestinationType, ContentType>] = [:]
    var systemNavigationActions: [SystemNavigationType : InterfaceAction<SystemNavigationType, DestinationType, ContentType>] = [:]
    var interactorAssistants: [UserInteractionType: any InteractorAssisting<TestColorsDestination>] = [:]

    var interfaceActionAssistants: [UserInteractionType: any InterfaceActionConfiguring<UserInteractionType, DestinationType, ContentType>] = [:]
    
    init(destinationConfigurations: DestinationConfigurations?, navigationConfigurations: NavigationConfigurations?, parentDestination: UUID? = nil) {
        self.parentDestinationID = parentDestination
        self.destinationConfigurations = destinationConfigurations
        self.systemNavigationConfigurations = navigationConfigurations
    }
    
    func configureInteractor(_ interactor: any Interactable, type: TestColorsDestination.InteractorType) {
        switch type {
            case .colors:

                if let datasource = interactor as? TestColorsDatasource {
                    datasource.startItemsRetrieval()
                }
                
        }
        
    }
    
    func subscribeToDatasource(datasource: TestColorsDatasource) {

        performRequest(interactor: .colors, request: TestColorsRequest(action: .retrieve)) { [weak self] result in
            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    self?.logError(error: error)
            }
        }


    }

    func performInterfaceAction(interactionType: UserInteractionType) {
        
        if var closure = interfaceActions[interactionType] {
            var routeType: RouteDestinationType?
            var contentType: ContentType?

            closure.data.parentID = self.parentDestinationID

            switch interactionType {
                case .color(model: let model):
                    routeType = RouteDestinationType.colorDetail

                    if let model {
                        contentType = .color(model: model)
                    }
                    
                    closure.data.contentType = contentType
                    closure.data.parentID = self.id

            }


            if let contentType {
                closure.data.contentType = contentType
            }
            
            if let routeType {
                closure.data.destinationType = routeType
            }
            
            closure()
        }
    }

}
