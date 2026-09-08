//
//  ContentTransformable.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A protocol that defines an object capable of transforming a value of one type into a value of another type.
///
/// Conforming types receive a value of the associated `Input` type, apply a transformation to it, and return a value of the associated `Output` type. The transformation may throw if the input is invalid or the transformation cannot be completed.
///
/// This protocol serves two roles in an ``ActionSequence``:
/// - **Transforming a sequence step's output for the next step**, via ``ActionSequenceConfiguration/step(_:inputTransformer:)`` or an ``ActionBranchConfiguration``'s `transformer` parameter. In this role `Input` and `Output` are typically the same type: the transformation changes the _value_, not the type (e.g. an array of images into an array of file models, both cases of the same content enum).
/// - **Converting an Interactor's raw request result into a sequence step's `ContentType`**, via ``ActionConfiguration``'s `resultTransformer` parameter. This is only needed when an Interactor's `Request.ResultData` type differs from the step's `ContentType`. For example, an API Interactor might define its own `ResultData` enum whose cases represent each supported endpoint, and a transformer packages that into the `ContentType` used elsewhere in the sequence.
///
/// ## Example: transforming a sequence step's output
/// In this example transformer we're taking an array of images as input and transforming them into an array of models containing the image data and filenames to save them to. Since this transforms a step's output for use by the next step, `Input` and `Output` are both inferred as `AppContentType`.
/// ```swift
/// struct ImageFileTransformer: ContentTransformable {
///     func transform(input: AppContentType) throws -> AppContentType {
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
///
/// ## Example: converting an Interactor's result
/// Here we're taking a `FilterResultType` value returned by an image-filtering Interactor and converting it into the `AppContentType` used throughout the rest of the sequence. `ResultData` (`FilterResultType`) and `ContentType` (`AppContentType`) are inferred as different types.
/// ```swift
/// struct ApplyImageFilterResultTransformer: ContentTransformable {
///     func transform(input: FilterResultType) throws -> AppContentType {
///         switch input {
///             case .filteredImages(let urls):
///                 return .savedFiles(urls: urls)
///         }
///     }
/// }
/// ```
@MainActor public protocol ContentTransformable<Input, Output>: Sendable {

    /// The type this transformer receives.
    associatedtype Input: ContentTypeable

    /// The content type this transformer produces.
    associatedtype Output: ContentTypeable

    /// Transforms the given input value and returns the converted result.
    ///
    /// - Parameter input: The value to transform.
    /// - Returns: The converted value in the form of a `ContentType`.
    /// - Throws: An error if the transformation cannot be applied to the given input.
    func transform(input: Input) throws -> Output
}
