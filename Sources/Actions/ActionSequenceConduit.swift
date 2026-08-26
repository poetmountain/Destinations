//
//  ActionSequenceConduit.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This object provides a unidirectional flow along an ``ActionSequence`` chain of Actions, optionally transforming output data from the previous Action before sending it on to the next Action.
public struct ActionSequenceConduit<ContentType: ContentTypeable>: ActionSequenceConduiting {
    
    public var outputAction: (any ActionPerformable<ContentType>)?
    public var transformer: (any ContentTransformable<ContentType>)?

    public init(outputAction: (any ActionPerformable<ContentType>)? = nil, transformer: (any ContentTransformable<ContentType>)? = nil) {
        self.outputAction = outputAction
        self.transformer = transformer
    }

    public func receive(input: ContentType, sequenceOutputs: ActionCollectionResults<ContentType>) async -> Result<ActionCollectionResults<ContentType>, Error> {
        
        var content: ContentType
        
        if let transformer {
            do {
                content = try transformer.transform(input: input)
            } catch {
                return .failure(ActionError<ContentType>.failed(partialResults: sequenceOutputs, error: error))
            }
        } else {
            content = input
        }
        
        return await outputAction?.perform(with: content, sequenceOutputs: sequenceOutputs) ?? .success(sequenceOutputs)
        
    }
    
}
