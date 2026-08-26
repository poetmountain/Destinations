//
//  SequenceDemoState.swift
//  ActionSequence
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import Destinations

@Observable
final class SequenceDemoState: StateModeling {

    typealias Destination = SequenceDemoView.Destination
    typealias SequenceStepType = SequenceDemoView.SequenceStepType

    var destination: Destination?

    /// The locations of the images written to disk by the sequence's save step.
    var savedFileURLs: [URL] = []

    /// A message describing the current state of the sequence.
    var statusMessage: String = "Tap the button to retrieve several photos in parallel and save them."

    /// Whether an action sequence is currently running.
    var isRunningSequence: Bool = false

    var downloadTask: Task<Void, Never>?
    
    let photoCount: Int = 4
    
    var shouldFilterImages: Bool = true

    init(destination: Destination? = nil) {
        self.destination = destination
    }

    func handleEvent(_ type: EventType, content: ContentType? = nil) {

        switch type {
            case .retrieveAndSaveImages:
                do {
                    try retrieveAndSaveImages()
                } catch {
                    print("sequence setup failed \(error)")
                }
        }
        
    }

    func retrieveAndSaveImages() throws {
        
        guard isRunningSequence == false else { return }
        
        isRunningSequence = true
        statusMessage = "Running ActionSequence…"
        savedFileURLs = []

        // Build the ActionSequence: a group step retrieves several images in parallel, then a save
        // step writes them all to disk.
        //
        // The group runs one retrieval action per image concurrently, and its RetrievedImagesMerger
        // merges the results into a single `images` value. That value flows through the output
        // conduit, whose transformer converts it into the file model content the save step expects.
        //
        // If the `shouldFilterImages` property is true, the branch then filters the images, otherwise skips.
                 
        // Here we're building an array of action sequences. Each one will retrieve an image and save it to disk.
        let retrieveImages: [any ActionConfiguring<InteractorType, ContentType>] = try (0..<photoCount).map { counter in
            let retrieveImage = ActionConfiguration<InteractorType, ContentType, ImageRetrievalInteractor>(
                interactorType: .imageRetrieval,
                action: .retrieve(imageURL: URL(string: "https://picsum.photos/600/400")!),
                assistant: .basicAsync,
                identifier: SequenceStepType.retrieveImage, shouldSaveResult: false)
            
            let imageSaver = ActionConfiguration<InteractorType, ContentType, SaveToDiskInteractor>(
                interactorType: .imageSaver,
                action: .save,
                assistant: .custom(SaveToDiskInteractorAssistant()),
                identifier: SequenceStepType.saveImage)
            
            return try ActionSequenceConfiguration<InteractorType, ContentType>()
                .step(retrieveImage)
                .output(using: ImageFileTransformer())
                .step(imageSaver)
  
                
        }

        // This is an ActionGroup whose actions are the image sequences we just built. These image retrievals will run in paralle and when complete, the `RetrievedImagesMerger` object will collate them into a content type containing an array of saved image URLs.
        let imageRetrievals = ActionGroupConfiguration<InteractorType, ContentType>(
            actions: retrieveImages,
            merger: RetrievedImagesMerger(),
            identifier: SequenceStepType.retrieveAndSaveImages,
            shouldSaveChildResults: false)
             
        // This step applies a filter to a group of images
        let filterImages = ActionConfiguration<InteractorType, ContentType, ApplyImageFilterInteractor>(
            interactorType: .imageFilter,
            action: .filter,
            assistant: .custom(ApplyImageFilterAssistant()),
            identifier: SequenceStepType.filterImages)
        
        // And here's the parent sequence that will be performed, first running the group of image retrievals
        // and then branching on whether to filter them or not
        let downloadAndSaveImages = try ActionSequenceConfiguration<InteractorType, ContentType>()
            .step(imageRetrievals)
            .output()
            .step(
                ActionBranchConfiguration(identifier: "shouldFilterBranch")
                .branch(when: BooleanCondition(shouldFilterImages), action: filterImages, transformer: nil)
                .otherwise(.skip)
            )
        
        downloadTask = Task { [weak self] in
            let result = await self?.destination?.performActions(configuration: downloadAndSaveImages, content: nil)
            
            switch result {
                case .success(let results):
                    // In this example the last step will contain the saved URLs of all retrieved images, either provided by
                    // the imageRetrievals group action or the filterImages branch action.
                    // If you have a specific step you want the result for, you can use `results.last(identifier:)`.
                    // Or if you have two branch actions that have the same output type you could give them the same
                    // identifier and use `results(matching:)` to pull whichever one was run.
                    if let groupAction = results.results.last {

                        switch groupAction.result {
                            case .success(let response):
                                if case .savedFiles(let urls) = response {
                                    self?.savedFileURLs = urls
                                }
                            case .failure(_):
                                break
                        }

                    }
                    
                    DestinationsSupport.logger.log("Sequence results: \(results.results.map { $0.content }) ")
                    
                    self?.statusMessage = "Sequence completed."

                case .failure(let error):
                    if case ActionError<ContentType>.cancelled(partialResults: let partialResults) = error {
                        self?.statusMessage = "Sequence cancelled after \(partialResults.results.count) completed step(s)."
                        let completedSteps = partialResults.results.compactMap { $0.content?.rawValue }.joined(separator: ", ")
                        DestinationsSupport.logger.log("Action sequence was cancelled. Results from completed steps: [\(completedSteps)]")

                    } else if case ActionError<ContentType>.failed(partialResults: let partialResults, error: let failureError) = error {
                        self?.statusMessage = "Sequence failed after \(partialResults.results.count) completed step(s)."
                        DestinationsSupport.logger.log("\(failureError)", category: .error)

                    } else {
                        self?.statusMessage = "Sequence failed: \(error)"
                        DestinationsSupport.logger.log("\(error)", category: .error)
                    }

                case .none: break
            }

            self?.isRunningSequence = false
        }
    }
    
    /// Cancels the in-progress action sequence.
    func cancelSequence() {
        guard isRunningSequence else { return }

        statusMessage = "Cancelling…"
        downloadTask?.cancel()
    }

    func cleanupResources() {
        downloadTask?.cancel()
    }
}
