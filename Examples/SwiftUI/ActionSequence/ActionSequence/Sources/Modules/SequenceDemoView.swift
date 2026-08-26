//
//  SequenceDemoView.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import SwiftUI
import UIKit
import Destinations

@Observable
final class SequenceDemoInterfaceState: DestinationStateable, DestinationTypes {

    typealias Destination = SequenceDemoView.Destination

    /// The Destination which user interaction events are sent to.
    var destination: Destination

    var stateModel: SequenceDemoState

    init(destination: Destination, state: SequenceDemoState) {
        self.destination = destination
        self.stateModel = state
    }
}

/// Demonstrates running an ActionSequence: retrieving a remote image, transforming the result with a custom `SequenceConduitTransformable`, and saving the image to disk.
struct SequenceDemoView: ViewDestinationInterfacing, DestinationTypes {

    enum Events: String, EventTypeable {
        case retrieveAndSaveImages
    }
    
    /// Tags for the steps of the demo's ActionSequence, used to locate each step's result in ``ActionSequenceResults``.
    enum SequenceStepType: ActionIdentifying {
        case retrieveImage
        case saveImage
        case filterImages
        case retrieveAndSaveImages
    }


    typealias EventType = Events
    typealias Destination = ViewDestination<SequenceDemoView, EventType, DestinationType, ContentType, TabType, InteractorType>

    @State var destinationState: SequenceDemoInterfaceState

    init(destination: Destination, state: SequenceDemoState) {
        self.destinationState = SequenceDemoInterfaceState(destination: destination, state: state)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("ActionSequence Demo")
                .font(.title2)
                .fontWeight(.semibold)

            Group {
                if stateModel.savedFileURLs.isEmpty {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 8)], spacing: 8) {
                        ForEach(Array(stateModel.savedFileURLs.enumerated()), id: \.offset) { _, url in
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            } placeholder: {
                                Color(.secondarySystemFill)
                                    .frame(maxWidth: .infinity)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

            Text(stateModel.statusMessage)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if stateModel.savedFileURLs.isEmpty == false {
                VStack(spacing: 4) {
                    Text("Saved \(stateModel.savedFileURLs.count) file(s):")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    ForEach(stateModel.savedFileURLs, id: \.self) { url in
                        Text(url.lastPathComponent)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
            
            VStack(alignment: .center) {

                HStack {
                    Toggle("Filter", isOn: Bindable(destinationState.stateModel).shouldFilterImages)
                        .disabled(stateModel.isRunningSequence)
                        .fixedSize()
                    
                }
                .padding(.bottom, 16)
                
                HStack(spacing: 12) {
                    Button(stateModel.isRunningSequence ? "Running…" : "Retrieve Photos") {
                        stateModel.handleEvent(.retrieveAndSaveImages)
                    }
                    .disabled(stateModel.isRunningSequence)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .foregroundStyle(.white)
                    .background(stateModel.isRunningSequence ? Color.gray : Color.blue)
                    .clipShape(Capsule())
                    
                    if stateModel.isRunningSequence {
                        Button("Cancel") {
                            stateModel.cancelSequence()
                        }
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .foregroundStyle(.white)
                        .background(Color.red)
                        .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 16)


            }
        }
        .padding()
    }
}

#Preview {
    // Build a minimal Destination and state to host the view, seeded with placeholder photos
    // so the preview shows the populated grid without running the ActionSequence.
    let destination = SequenceDemoView.Destination(destinationType: .sequenceDemo)
    let state = SequenceDemoState(destination: destination)

    state.savedFileURLs = (0..<3).map { URL(fileURLWithPath: "/tmp/fetched-image-\($0).png") }
    state.statusMessage = "Sequence completed: retrieved 3 photos in parallel and saved 3 to disk."

    return SequenceDemoView(destination: destination, state: state)
}
