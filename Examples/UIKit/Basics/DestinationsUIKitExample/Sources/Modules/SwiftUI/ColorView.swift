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
  
    enum UserInteractions: UserInteractionTypeable {
        case changeColor
        case test
        
        var rawValue: String {
            switch self {
                case .changeColor:
                    return "changeColor"
                case .test:
                    return "test"
            }
        }
        
        static func == (lhs: UserInteractions, rhs: UserInteractions) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
    
    typealias PresentationConfiguration = DestinationPresentation<DestinationType, AppContentType, TabType>
    typealias UserInteractionType = UserInteractions
    typealias Destination = ViewDestination<ColorView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    
    var destinationState: DestinationInterfaceState<Destination>

    @State var hostingState: SwiftUIHostingState<ColorView, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>
    
    @State var colorModel: ColorViewModel?

    init(model: ColorViewModel? = nil, parentDestination: SwiftUIContainerDestination<Self, UserInteractionType, DestinationType, ContentType, TabType, InteractorType>) {
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
            
            Button("Change color") {
                hostingState.destination.handleThrowable { [weak hostingState] in
                    try hostingState?.destination.performInterfaceAction(interactionType: .changeColor, content: .color(model: ColorViewModel(color: .systemGreen, name: "Green")))
                }
            }
        }
    }

}
