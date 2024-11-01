//
//  DestinationsSwiftUIApp.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

@main
struct DestinationsSwiftUIApp: App, DestinationTypes {

    @State var rootView: (any View)?
    
    @State var hasStartedAppFlow = false
    
    @State var appFlow: ViewFlow<DestinationType, TabType, ContentType>?
    
    @State private var startDestinationID: UUID = UUID()
    
    func buildAppFlow() -> ViewFlow<DestinationType, TabType, ContentType> {
        
        DestinationsOptions.logger.options.maximumOutputLevel = .verbose
        //DestinationsOptions.logger.shouldUseFileInfo = true
        //DestinationsOptions.logger.shouldUseMethodInfo = true

        let startingTabs: [AppTabType] = [.palettes, .home]
        let startingType: RouteDestinationType = .tabBar(tabs: startingTabs)
        let startingDestination = PresentationConfiguration(destinationType: startingType, presentationType: .replaceCurrent, assistantType: .basic)
        
        let homepath: [PresentationConfiguration] = [
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .purple, name: "purple")), assistantType: .basic),
            PresentationConfiguration(destinationType: .colorDetail, presentationType: .tabBar(tab: .palettes), contentType: .color(model: ColorViewModel(color: .magenta, name: "magenta")), assistantType: .basic)
        ]
        
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationController(type: .present), assistantType: .custom(ChooseColorFromListActionAssistant()))
        
        let homePathPresent = PresentationConfiguration(presentationType: .destinationPath(path: homepath), assistantType: .basic)
        let options = ViewSheetPresentationOptions(presentationMode: .sheet)
        let sheetPresent = PresentationConfiguration(destinationType: .dynamic, presentationType: .sheet(type: .present, options: SheetPresentationOptions(swiftUI: options)), assistantType: .custom(ColorDetailActionAssistant()))

        let colorsListProvider = ColorsListProvider(presentationsData: [.color(model: nil): colorSelection], interactorsData: [.moreButton: InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate)])
        let colorDetailProvider = ColorDetailProvider(presentationsData: [.colorDetailButton: sheetPresent])
        let homeProvider = HomeProvider(presentationsData: [.pathPresent: homePathPresent])
        let dynamicProvider = DynamicProvider()
        let tabBarProvider = TabBarProvider()

        let providers: [RouteDestinationType: any ViewDestinationProviding] = [
            .colorsList: colorsListProvider,
            .colorDetail: colorDetailProvider,
            .home: homeProvider,
            .dynamic: dynamicProvider,
            .tabBar(tabs: startingTabs): tabBarProvider
        ]
        
        return ViewFlow<DestinationType, TabType, ContentType>(destinationProviders: providers, startingDestination: startingDestination)
    }
    
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasStartedAppFlow && !isAppRunningTests() {
                    appFlow?.startingDestinationView()
                }
            }
            .onAppear(perform: {
                if (hasStartedAppFlow == false && !self.isAppRunningTests()) {
                    self.appFlow = buildAppFlow()
                    self.appFlow?.start()
                    hasStartedAppFlow = true

                }
            })
        }
    }
    
    func isAppRunningTests() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    }
}


extension ViewDestination: DestinationTypes {}
