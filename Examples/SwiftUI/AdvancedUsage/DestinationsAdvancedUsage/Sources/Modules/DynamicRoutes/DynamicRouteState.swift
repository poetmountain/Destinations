//
//  DynamicRouteState.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation
import Destinations

@Observable
final class DynamicRouteState: StateModeling {
    typealias Destination = DynamicRouteView.Destination
    typealias EventType = DynamicRouteView.EventType
    typealias InteractorType = Destination.InteractorType
    typealias ContentType = Destination.ContentType

    var destination: Destination?

    var selectedRoute: Route = .welcome

    func handleEvent(_ type: EventType, content: ContentType? = nil) {
        switch type {
            case .navigate:
                destination?.handleThrowable(closure: { [weak destination, weak self] in
                    guard let strongSelf = self else { return }
                    try destination?.performAction(for: type, content: .route(strongSelf.selectedRoute))
                })
        }
    }

}
