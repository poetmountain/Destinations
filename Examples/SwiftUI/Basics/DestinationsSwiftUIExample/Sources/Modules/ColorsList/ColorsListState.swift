//
//  ColorsListState.swift
//  DestinationsSwiftUIExample
//
//  Created by Brett Walker on 5/16/26.
//

import Foundation
import Destinations

/// Demonstrates the ability to swap state models by using a protocol
@MainActor protocol ColorsListStateModeling: StateModeling, AnyObject, Identifiable where Destination == ColorsListView.Destination {
    
    typealias EventType = ColorsListView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType
    
    var id: UUID { get }

    var items: [ColorViewModel] { get set }

    var selectedItem: ColorViewModel.ID? { get set }
}


@Observable
final class ColorsListState: ColorsListStateModeling {


    let id = UUID()

    var destination: Destination?

    var items: [ColorViewModel] = []

    var selectedItem: ColorViewModel.ID?
    
    var tasks: [Task<Void, Never>] = []

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType? = nil) {

        switch type {
            case .retrieveInitialColors, .moreButton:
                
                let task = Task {
                    let result = await destination?.performAction(for: type, content: content)
                    
                    switch result {
                        case .success(let content):
                            if case .colors(models: let models) = content {
                                items = models
                            }
                        case .failure(let error):
                            DestinationsSupport.logger.log("error \(error.localizedDescription)", category: .error)
                        case .none: break
                    }
                }
                tasks.append(task)

            case .color:
                destination?.handleThrowable(closure: { [weak destination] in
                     try destination?.performAction(for: type, content: content)
                 })
        }
    }


    func prepareForPresentation() {
        handleEvent(.retrieveInitialColors)
    }
}
