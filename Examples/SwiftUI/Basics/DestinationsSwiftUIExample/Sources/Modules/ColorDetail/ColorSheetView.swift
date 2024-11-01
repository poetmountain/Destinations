//
//  ColorSheetView.swift
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI

struct ColorSheetView: View {
    
    @State var dismissButtonClosure: (() -> Void)?
    
    @State private var colorModel: ColorViewModel?

    init(colorModel: ColorViewModel? = nil, dismissButtonClosure: @escaping () -> Void) {
        _dismissButtonClosure = State.init(initialValue: dismissButtonClosure)
        if let colorModel {
            _colorModel = State.init(initialValue: colorModel)
        }

    }
    

    var body: some View {
        GeometryReader { metrics in
            let rect = CGRect(origin: .zero, size: metrics.size)
            
            VStack {
                
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Button("Dismiss") {
                            dismissButtonClosure?()
                        }
                        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .padding(.trailing, 12)
                    }
                }
                .frame(width: rect.width)
                .frame(maxHeight: 50)
                .containerRelativeFrame(.horizontal, alignment: .trailing)

                Spacer(minLength: 50)
                
                Rectangle()
                    .fill(Color(colorModel?.color ?? .black))
                    .frame(width: 100, height: 100)
                if let name = colorModel?.name {
                    Text(name)
                }
                Spacer()
            }
        }
    }
}
