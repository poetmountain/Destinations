//
//  CounterView.swift
//  DestinationsSwiftUIExample
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct CounterView: ViewDestinationInterfacing, DestinationTypes {
    
    typealias UserInteractionType = CounterDestination.UserInteractions
    typealias Destination = CounterDestination
        
    @State var destinationState: DestinationInterfaceState<Destination>
                        
    init(destination: Destination, sheetView: ContainerView<AnyView>? = nil) {
        self.destinationState = DestinationInterfaceState(destination: destination)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Text("Counter")
                .font(.system(size: 24, weight: .semibold))
            Text("\(destinationState.destination.counter)")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemBlue.cgColor))
            
            Spacer()
            
            HStack {
                Button("Start counter") {
                    destination().handleThrowable(closure: {
                        try destination().performInterfaceAction(interactionType: .start)
                    })
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(Capsule())
                
                Button("Stop counter") {
                    destination().handleThrowable(closure: {
                        try destination().performInterfaceAction(interactionType: .stop)
                    })
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .padding(.bottom, 50)

        }

    }

}
