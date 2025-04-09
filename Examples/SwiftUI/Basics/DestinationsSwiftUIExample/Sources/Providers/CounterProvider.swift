//
//  CounterProvider.swift
//  DestinationsSwiftUIExample
//
//  Created by Brett Walker on 2/28/25.
//

import Foundation
import Destinations

struct CounterProvider: ViewDestinationProviding, DestinationTypes {
    
    public typealias Destination = CounterDestination
    
    public var presentationsData: [Destination.UserInteractionType: PresentationConfiguration] = [:]
    public var interactorsData: [Destination.UserInteractionType : any InteractorConfiguring<Destination.InteractorType>] = [:]
    
    init() {
        let startCountAction = InteractorConfiguration<CounterDestination.InteractorType, CounterInteractor>(interactorType: .counter, actionType: .startCount, assistantType: .custom(CounterInteractorAssistant(actionType: .startCount)))
        let stopCountAction = InteractorConfiguration<CounterDestination.InteractorType, CounterInteractor>(interactorType: .counter, actionType: .stopCount, assistantType: .custom(CounterInteractorAssistant(actionType: .stopCount)))
        
        interactorsData = [.start: startCountAction, .stop: stopCountAction]
    }
    
    public func buildDestination(destinationPresentations: AppDestinationConfigurations<Destination.UserInteractionType, DestinationType, ContentType, TabType>?, navigationPresentations: AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>?, configuration: DestinationPresentation<DestinationType, ContentType, TabType>, appFlow: some ViewFlowable<DestinationType, ContentType, TabType>) -> Destination? {
        
        let destination = CounterDestination(destinationConfigurations: destinationPresentations, navigationConfigurations: navigationPresentations, parentDestination: configuration.parentDestinationID)

        let counterView = CounterView(destination: destination)
        destination.assignAssociatedView(view: counterView)

        let interactor = CounterInteractor()
        destination.assignInteractor(interactor: interactor, for: .counter)
                
         return destination
        
    }
    


}
