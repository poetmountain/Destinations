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

final class CounterInteractor: SyncInteractable {

    typealias Request = CounterRequest
    typealias Item = Request.Item

    var requestResponses: [Request.ActionType: InteractorResponseClosure<Request>] = [:]
        
    private var counter: Int = 0
    
    private var isCounting = false
    
    let (stream, continuation) = AsyncStream.makeStream(of: Int.self)

    private var timer: Timer?
    
    deinit {
        stopStream()
        continuation.finish()
    }
    
    func perform(request: Request) {
        
        switch request.action {
            case .startCount:
                startStream()

            case .stopCount:
                stopStream()
        }
        
    }

    private func startStream() {
        print("starting stream")
        guard isCounting == false else { return }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [continuation] timer in            
            continuation.yield(1)
        })

        isCounting = true
    }

    nonisolated private func stopStream() {
        print("stopping stream")

        timer?.invalidate()
        timer = nil
        isCounting = false
    }
}
