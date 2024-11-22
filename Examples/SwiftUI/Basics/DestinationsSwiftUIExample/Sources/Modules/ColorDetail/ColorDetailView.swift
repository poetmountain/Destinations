//
//  ColorDetailView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations
import Combine

struct ColorDetailView: ViewDestinationInterfacing, SheetPresenting, DestinationTypes {
    
    typealias UserInteractionType = ColorDetailDestination.UserInteractions
    typealias Destination = ColorDetailDestination
        
    @State var destinationState: DestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
            
    @State private var colorModel: ColorViewModel?
    
    @State var sheetPresentation = SheetPresentation()
    
    @State var sheetView: ContainerView<AnyView>?
    
    init(destination: Destination, model: ColorViewModel? = nil, sheetView: ContainerView<AnyView>? = nil) {
        self.destinationState = DestinationInterfaceState(destination: destination)

        if let model {
            _colorModel = State.init(initialValue: model)
        }
        
        if let sheetView {
            _sheetView = State.init(initialValue: sheetView)
        }
    }
    
    mutating func updateSheetView(sheetView: ContainerView<AnyView>) {
        
        _sheetView = State.init(initialValue: sheetView)
    }
    
    var body: some View {
        VStack {
            Text("Color \(colorModel?.name ?? "")")
            Circle()
                .fill(Color(colorModel?.color ?? .black))
                .frame(width: 200, height: 200)

            Button(action: { [weak destination = destination()] in
                guard let sheetView else { return }
                
                destination?.handleThrowable(closure: {
                    try destination?.performInterfaceAction(interactionType: .colorDetailButton, content: .dynamicView(view: sheetView))
                })
                
            }, label: {
                Text("Present")
            })

        }
        .destinationSheet(presentation: sheetPresentation)

    }

}


struct ColorDetailSelectionModel: Hashable {
    
    var color: ColorViewModel?
    var targetID: UUID?
    
}

public struct DynamicViewModel: Equatable, Hashable {
    
    let id: UUID = UUID()
    
    var view: ContainerView<AnyView>?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
