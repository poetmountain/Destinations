//
//  CounterState.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class CounterState: StateModeling {
    typealias Destination = CounterView.Destination
    typealias EventType = CounterView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var counter: Int = 0

    func handleEvent(_ type: EventType, content: ContentType? = nil) {
        switch type {
            case .start, .stop:

                destination?.handleThrowable(closure: { [weak destination] in
                    try destination?.performAction(for: type)
                })
        }
    }
    
    func handleAsyncInteractorResult<Request>(result: Result<Request.ResultData, any Error>, for request: Request) async where Request : InteractorRequestConfiguring {

        switch result {
            case .success(let response):
                if case .count(value: let value, isFinished: let isFinished) = response as? CounterRequest.ResultData {
                    print("counter value received: \(value) - finished? \(isFinished)")
                    counter = value
                }
            case .failure(let error):
                print("error \(error)")
        }
    }

    func handleStartButtonTapped() {
        handleEvent(.start, content: nil)
    }

    func handleStopButtonTapped() {
        handleEvent(.stop, content: nil)
    }

    func cleanupResources() {
        destination?.interactor(for: .counter)?.cleanupResources()
    }
}
