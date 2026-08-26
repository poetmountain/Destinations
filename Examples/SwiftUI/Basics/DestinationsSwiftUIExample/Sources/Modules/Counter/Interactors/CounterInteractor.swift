//
//  CounterInteractor.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

struct CounterRequest: InteractorRequestConfiguring {
  
    enum ActionType: InteractorRequestActionTypeable {
        case startCount
        case stopCount
    }
    
    typealias RequestContentType = AppContentType
    typealias ResultData = AppContentType
    typealias Item = Int

    var action: ActionType
}

actor CounterInteractor: AsyncInteractable {
    
    typealias Request = CounterRequest

    var requestResponses: [Request.ActionType: InteractorResponseClosure<Request>] = [:]
        
    var counter: Int = 0
    
    private(set) var isCounting = false
    
    var stream: AsyncStream<Int>?
    var continuation: AsyncStream<Int>.Continuation?
        
    deinit {
        continuation?.finish()
    }
    
    nonisolated func cleanupResources() {
        Task { @MainActor [weak self] in
            await self?.continuation?.finish()
        }
    }
    
    func perform(request: CounterRequest) async -> Result<CounterRequest.ResultData, Error> {
        switch request.action {
            case .startCount:
                await startStream()
                return .success(.count(value: counter, isFinished: false))
            case .stopCount:
                stopStream()
                return .success(.count(value: counter, isFinished: true))
        }
    }

    func startStream() async {
        guard isCounting == false else { return }
        isCounting = true
        print("starting stream")
        
        (stream, continuation) = makeStream()
        
    }

    private func stopStream() {
        print("stopping stream")
        isCounting = false
        continuation?.finish()
        stream = nil
        
    }
    
    func makeStream() -> (AsyncStream<Int>, AsyncStream<Int>.Continuation?) {
        
        var streamContinuation: AsyncStream<Int>.Continuation?
        
        let stream = AsyncStream { continuation in
            streamContinuation = continuation
            
            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1))
                    if isCounting {
                        counter += 1
                        continuation.yield(counter)
                    }
                }
                print("Counter task cancelled!")
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        
        return (stream, streamContinuation)
    }
}
