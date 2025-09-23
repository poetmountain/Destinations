//
//  ColorDetailView.swift
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorDetailView: ViewDestinationInterfacing, DestinationTypes {
    
    typealias UserInteractionType = ColorDetailSwiftUIDestination.UserInteractions
    typealias Destination = ColorDetailSwiftUIDestination
        
    @State var destinationState: DestinationInterfaceState<Destination>

    @State var areDatasourcesSetup = false
            
    @State private var colorModel: ColorViewModel?
    

    init(destination: Destination, model: ColorViewModel? = nil) {
        self.destinationState = DestinationInterfaceState(destination: destination)
        
        if let model {
            _colorModel = State.init(initialValue: model)
        }
        

    }
    
    
    var body: some View {

        VStack(alignment: .leading) {

                VStack {
                    Text("Color \(colorModel?.name ?? "")")
                    Circle()
                        .fill(Color(colorModel?.color ?? .black))
                        .frame(width: 200, height: 200)

                }
  

            Spacer()

        }
    }
        

}


public struct DynamicViewModel: Equatable, Hashable {
    
    let id: UUID = UUID()
    
    var view: ContainerView<AnyView>?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
