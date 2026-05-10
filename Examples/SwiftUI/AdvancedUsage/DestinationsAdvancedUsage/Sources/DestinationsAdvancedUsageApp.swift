//
//  DestinationsAdvancedUsageApp.swift
//  DestinationsAdvancedUsage
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.


import SwiftUI
import Destinations

@main
struct DestinationsAdvancedUsageApp: App, DestinationTypes {

    @State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?
    @State var hasStartedAppFlow = false

    func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {
        let startingDestination = PresentationConfiguration(
            destinationType: .dynamic,
            presentationType: .replaceCurrent,
            assistantType: .basic
        )

        let providers: [Route: any ViewDestinationProviding] = [
            .dynamic: DynamicRouteProvider(),
            .welcome: WelcomeProvider(),
            .info: InfoProvider(),
        ]

        return ViewFlow<DestinationType, TabType, ContentType>(
            destinationProviders: providers,
            startingDestination: startingDestination
        )
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasStartedAppFlow {
                    appFlow?.startingDestinationView()
                }
            }
            .onAppear {
                if !hasStartedAppFlow {
                    self.appFlow = buildAppFlow()
                    self.appFlow?.start()
                    hasStartedAppFlow = true
                }
            }
        }
    }
}

extension ViewDestination: DestinationTypes {}
