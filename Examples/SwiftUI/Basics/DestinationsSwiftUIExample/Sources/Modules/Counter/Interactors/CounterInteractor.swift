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
    typealias Item = Request.Item

    var requestResponses: [Request.ActionType: InteractorResponseClosure<Request>] = [:]
        
    private var counter: Int = 0
    
    private(set) var isCounting = false
    
    let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

    private var timer: Task<Void, Never>?
    
    deinit {
        cleanupResources()
    }
    
    nonisolated func cleanupResources() {
        Task { @MainActor [weak self] in
            await self?.timer?.cancel()
            self?.continuation.finish()
        }
    }
    
    func perform(request: CounterRequest) async -> Result<CounterRequest.ResultData, Error> {
        switch request.action {
            case .startCount:
                startStream()
                return .success(.count(value: counter))
            case .stopCount:
                stopStream()
                return .success(.count(value: counter))
        }
    }

    func startStream() {
        guard isCounting == false else { return }
        print("starting stream")
        
        timer = Task(priority: .utility) {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
                
                if isCounting {
                    continuation.yield(1)
                }
            }
        }
    

        isCounting = true
    }

    private func stopStream() {
        print("stopping stream")
        timer?.cancel()
        isCounting = false
    }
}
