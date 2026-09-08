//
//  InteractorResultTransformerWrapper.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol stands as a witness behind ``ContentTransformerWrapper``'s type erasure. A separate, primary-associated-type protocol is needed here so that the wrapper's storage is dispatched through a witness table, allowing its `Sendable` conformance to be proven.
@MainActor private protocol ContentTransformerBoxing<ContentType>: Sendable {

    associatedtype ContentType: ContentTypeable

    func transform(result: Any) throws -> ContentType
}

/// A concrete witness for the ``ContentTransformerBox`` protocol, which holds a typed ``ContentTransformable`` object directly.
@MainActor private struct ConcreteContentTransformerBox<Transformer: ContentTransformable>: ContentTransformerBoxing {

    typealias ContentType = Transformer.Output

    let transformer: Transformer

    func transform(result: Any) throws -> ContentType {
        guard let typedResult = result as? Transformer.Input else {
            let template = DestinationsSupport.errorMessage(for: .incompatibleType(message: ""))
            let message = String(format: template, "\(result)")
            throw DestinationsError.incompatibleType(message: message)
        }
        return try transformer.transform(input: typedResult)
    }
}

/// A type-erased box wrapping any object conforming to ``ContentTransformable`` for a specific `ContentType`.
///
/// `Action` doesn't know the concrete `Request.ResultData` type of the Interactor whose assistant it holds. That type only exists at ``ActionConfiguration``'s generic scope where the Interactor assistant is built. `ContentTransformerWrapper` bridges that gap: `ActionConfiguration` wraps a typed ``ContentTransformable`` object in the wrapper and `Action` stores it.
///
/// Internally this stores the wrapped transformer inside a generic ``ConcreteContentTransformerBox``, dispatched through the ``ContentTransformerBox`` witness table, which lets this type conform to `Sendable` unconditionally.
@MainActor public struct ContentTransformerWrapper<ContentType: ContentTypeable>: Sendable {

    private let box: any ContentTransformerBoxing<ContentType>

    /// Wraps the given transformer, erasing its `ResultData` type.
    /// - Parameter transformer: The typed transformer to wrap.
    public init<Transformer: ContentTransformable>(_ transformer: Transformer) where Transformer.Output == ContentType {
        self.box = ConcreteContentTransformerBox(transformer: transformer)
    }

    /// Converts the given raw result into `ContentType` using the wrapped transformer.
    /// - Parameter result: The raw result data returned by the Interactor.
    /// - Returns: The converted value in the form of a `ContentType`.
    /// - Throws: An error if the wrapped transformer's conversion fails, or if `result` isn't the type the wrapped transformer expects.
    func transform(result: Any) throws -> ContentType {
        try box.transform(result: result)
    }
}
