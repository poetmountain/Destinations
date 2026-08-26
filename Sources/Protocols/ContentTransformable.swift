//
//  ContentTransformable.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines an object capable of transforming content from one type to another, but typically used to transform the output of a sequence step. This is a necessary part of providing usable input from the previous sequence step's output.
///
/// Conforming types receive a value of the associated `ContentType`, apply a transformation to it, and then return the modified result. The transformation may throw if the input is invalid or the transformation cannot be completed.
///
/// Implement this protocol to transform the output of an ``Action`` before it is injected as an input into the next step in an ``ActionSequence``.
///
/// ## Example
/// In this example transformer we're taking an array of images as input and transforming them into an array of models containing the image data and filenames to save them to.
/// ```swift
/// struct ImageFileTransformer: ContentTransformable {
///     func transform(input: ContentType) throws -> ContentType {
///         guard case .images(let images) = input else { return input }
///
///         let timestamp = Int(Date().timeIntervalSince1970)
///         let models: [DataModel] = try images.enumerated().map { index, image in
///             guard let data = image.pngData() else {
///                 throw SequenceDemoError.invalidImage
///             }
///             return DataModel(data: data, fileName: "fetched-image-\(timestamp)-\(index).png")
///         }
///     }
/// }
/// ```
@MainActor public protocol ContentTransformable<ContentType> {
    
    /// The content type this transformer operates on.
    associatedtype ContentType: ContentTypeable

    /// Transforms the given input value and returns the modified result.
    ///
    /// - Parameter input: The content value produced by the current sequence step.
    /// - Returns: A transformed copy of `input`.
    /// - Throws: An error if the transformation cannot be applied to the given input.
    func transform(input: ContentType) throws -> ContentType
}
