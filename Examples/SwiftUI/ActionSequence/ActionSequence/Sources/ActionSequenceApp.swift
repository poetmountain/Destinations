//
//  ActionSequenceApp.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@main
struct ActionSequenceApp: App, DestinationTypes {

    @State var hasStartedAppFlow = false

    @State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?

    func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {

        DestinationsSupport.logger.options.maximumOutputLevel = .verbose

        let startingDestination = PresentationConfiguration(destinationType: .sequenceDemo, presentationType: .replaceCurrent, assistantType: .basic)

        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .sequenceDemo: SequenceDemoProvider()
        ]

        return ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasStartedAppFlow {
                    appFlow?.startingDestinationView()
                }
            }
            .onAppear(perform: {
                if (hasStartedAppFlow == false) {
                    self.appFlow = buildAppFlow()
                    self.appFlow?.start()

                    hasStartedAppFlow = true
                }
            })
        }
    }

}
