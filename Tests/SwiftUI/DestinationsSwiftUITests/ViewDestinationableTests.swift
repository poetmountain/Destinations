//
//  ViewDestinationableTests.swift
///
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import XCTest
import SwiftUI
@testable import DestinationsSwiftUI
import Destinations

@MainActor final class ViewDestinationableTests: XCTestCase, DestinationTypes {

    override func setUp() async throws {
        DestinationsSupport.logger.options.maximumOutputLevel = .error
    }
    
    func test_assignInteractor() {
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        let colorsListConfigs = AppDestinationConfigurations<ColorsListView.EventType, DestinationType, ContentType, TabType>(configurations: [.color(model: nil): colorSelection])
        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>(configurations: [:])

        let destination = ColorsListView.Destination(destinationType: .colorsList, destinationConfigurations: colorsListConfigs, navigationConfigurations: navigationConfigs, parentDestination: nil)
        let state = ColorsListState(destination: destination)
        destination.stateModel = state
        let listView = ColorsListView(destination: destination, state: state)
        destination.assignAssociatedView(view: listView)

        let datasource = ColorsDatasource()
        destination.assignInteractor(datasource, to: .colors)
        
        XCTAssertNotNil(listView.destination().internalState.interactors[ColorsListView.InteractorType.colors])

    }

    func test_presentSheet_succeeds_when_no_sheet_is_currently_presented() {
        let destination = ColorDetailView.Destination(destinationType: .colorDetail, destinationConfigurations: nil, navigationConfigurations: nil, parentDestination: nil)
        let state = ColorDetailState()
        destination.stateModel = state
        let view = ColorDetailView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        let sheetView = ContainerView { AnyView(EmptyView()) }
        let sheet = Sheet(destinationID: destination.id, view: sheetView)

        let didPresent = destination.presentSheet(sheet: sheet)

        XCTAssertTrue(didPresent)
        XCTAssertEqual(state.sheetPresentation.sheet?.id, sheet.id)
    }

    func test_presentSheet_fails_when_a_sheet_is_already_presented() {
        let destination = ColorDetailView.Destination(destinationType: .colorDetail, destinationConfigurations: nil, navigationConfigurations: nil, parentDestination: nil)
        let state = ColorDetailState()
        destination.stateModel = state
        let view = ColorDetailView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        let firstSheetView = ContainerView { AnyView(EmptyView()) }
        let firstSheet = Sheet(destinationID: destination.id, view: firstSheetView)
        let didPresentFirst = destination.presentSheet(sheet: firstSheet)

        let secondSheetView = ContainerView { AnyView(EmptyView()) }
        let secondSheet = Sheet(destinationID: UUID(), view: secondSheetView)
        let didPresentSecond = destination.presentSheet(sheet: secondSheet)

        XCTAssertTrue(didPresentFirst)
        XCTAssertFalse(didPresentSecond)
        XCTAssertEqual(state.sheetPresentation.sheet?.id, firstSheet.id)
    }

    func test_presentSheet_succeeds_again_after_previous_sheet_is_dismissed() {
        let destination = ColorDetailView.Destination(destinationType: .colorDetail, destinationConfigurations: nil, navigationConfigurations: nil, parentDestination: nil)
        let state = ColorDetailState()
        destination.stateModel = state
        let view = ColorDetailView(destination: destination, state: state)
        destination.assignAssociatedView(view: view)

        let firstSheetView = ContainerView { AnyView(EmptyView()) }
        let firstSheet = Sheet(destinationID: destination.id, view: firstSheetView)
        XCTAssertTrue(destination.presentSheet(sheet: firstSheet))

        state.sheetPresentation.removeCurrentSheet()

        let secondSheetView = ContainerView { AnyView(EmptyView()) }
        let secondSheet = Sheet(destinationID: UUID(), view: secondSheetView)
        let didPresentSecond = destination.presentSheet(sheet: secondSheet)

        XCTAssertTrue(didPresentSecond)
        XCTAssertEqual(state.sheetPresentation.sheet?.id, secondSheet.id)
    }

    func test_presentSheet_fails_when_stateModel_does_not_conform_to_SheetPresenting() {
        let colorSelection = PresentationConfiguration(destinationType: .colorDetail, presentationType: .navigationStack(type: .present), assistantType: .basic)
        let colorsListConfigs = AppDestinationConfigurations<ColorsListView.EventType, DestinationType, ContentType, TabType>(configurations: [.color(model: nil): colorSelection])
        let navigationConfigs = AppDestinationConfigurations<SystemNavigationType, DestinationType, ContentType, TabType>(configurations: [:])

        let destination = ColorsListView.Destination(destinationType: .colorsList, destinationConfigurations: colorsListConfigs, navigationConfigurations: navigationConfigs, parentDestination: nil)
        let state = ColorsListState(destination: destination)
        destination.stateModel = state
        let listView = ColorsListView(destination: destination, state: state)
        destination.assignAssociatedView(view: listView)

        let sheetView = ContainerView { AnyView(EmptyView()) }
        let sheet = Sheet(destinationID: destination.id, view: sheetView)

        let didPresent = destination.presentSheet(sheet: sheet)

        XCTAssertFalse(didPresent)
    }

}
