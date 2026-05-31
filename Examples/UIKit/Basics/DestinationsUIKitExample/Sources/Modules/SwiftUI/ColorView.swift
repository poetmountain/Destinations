//
//  ColorView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import Destinations

struct ColorView: ViewDestinationInterfacing, SwiftUIHostedInterfacing, DestinationTypes {
  
    enum Events: EventTypeable {
        case changeTab
        
        var rawValue: String {
            switch self {
                case .changeTab:
                    return "changeTab"
            }
        }
        
        static func == (lhs: Events, rhs: Events) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias EventType = Events
    typealias Destination = ViewDestination<ColorView, EventType, DestinationType, ContentType, TabType, InteractorType>
    
    var destinationState: DestinationInterfaceState<Destination>

    @State var hostingState: SwiftUIHostingState<ColorView, EventType, DestinationType, ContentType, TabType, InteractorType>
    
    @State var colorModel: ColorViewModel?

    init(model: ColorViewModel? = nil, parentDestination: SwiftUIContainerDestination<Self, EventType, DestinationType, ContentType, TabType, InteractorType>) {
        let destination = Destination(destinationType: .colorDetail)
        self.destinationState = DestinationInterfaceState(destination: destination)
        self.hostingState = SwiftUIHostingState(destination: parentDestination)
        
        if let model = model {
            _colorModel = State.init(initialValue: model)
        }
    }
    
    var body: some View {
        VStack {
            Text("This is a SwiftUI View!")
            .padding(.bottom, 100)
            .bold()
            Text("\(colorModel?.name ?? "")")
            Circle()
                .fill(Color(colorModel?.color ?? .black))
                .frame(width: 200, height: 200)
            
            Button("Switch tab to Palettes") {
                hostingState.destination.handleEvent(.changeTab)
            }
        }
    }

}
