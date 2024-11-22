//
//  SplitViewSwiftUIExampleApp.swift
//  SplitViewSwiftUIExample
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@main
struct SplitViewSwiftUIExampleApp: App, AppDestinationTypes {

    @State var rootView: (any View)?
    
    @State var hasStartedAppFlow = false
    
    @State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?
    
    @State private var startDestinationID: UUID = UUID()
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>

    func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {
        
        DestinationsSupport.logger.options.maximumOutputLevel = .verbose
        //DestinationsSupport.logger.shouldUseFileInfo = true
        //DestinationsSupport.logger.shouldUseMethodInfo = true

        let startingDestination = PresentationConfiguration(destinationType: .splitView, presentationType: .replaceCurrent, assistantType: .basic)

        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .splitView(column: SplitViewColumn(swiftUI: .detail)), assistantType: .custom(ChooseColorFromListActionAssistant()))
 
        let splitViewProvider = SplitViewProvider(initialContent: [.sidebar: .colorsList, .detail: .colorDetail])
        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection])
        let colorDetailProvider = ColorDetailProvider()


        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .splitView: splitViewProvider,
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider
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

extension ViewDestination: AppDestinationTypes {}
