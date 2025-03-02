//
//  Interactable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This is an abstract protocol representing an Interactor object. Please see the important notice below for choosing the correct protocol for your Interactors.
///
/// Interactors provide an interface to perform some business logic, often acting as a datasource by interfacing with an API, handling system APIs, or some other self-contained work.
///
///  The concept of Interactors comes from [Clean Swift](https://clean-swift.com), used in its architecture as a way to move logic and datasource management out of view controllers. In Destinations, the `Interactable` protocol represents Interactor objects which provide an interface to perform some logic or data request, typically by interfacing with an backend API, handling system APIs, or some other self-contained work. `Datasourceable` inherits from this protocol and should be used for objects which specifically represent a datasource of some kind. There are also Actor-based async versions of these protocols available.
///
///  Though requests to Interactors can be made using a Destination's `performRequest` method, in general one should use the `performInterfaceAction` method. This abstracts the specific implementation details of an interactor away from the interface and lets it focus on making requests through a standardized request.
///
///  The recommended way is to assign a user interaction type to your request and using an `InteractorAssisting`-conforming assistant to configure the request, leaving the Destination's interface free of associated business logic.
///
///  Interactors are typically created by Destination providers and stored in the Destination. Like with presentations of new Destinations, Interactor requests are associated with a particular `InterfaceAction` object and are represented by an `InteractorConfiguration` model object. Action types for each Interactor are defined as enums, keeping Interactor-specific knowledge out of the interface.
///
///  For example, here we're creating an Interactor action for making a pagination request to the ColorsDatasource, and then assign it to a `moreButton` user interaction type:
///  ```swift
///  let paginateAction = InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate, assistantType: .basic)
///  let colorsProvider = ColorsListProvider(interactorsData: [.moreButton: paginateAction])
///  ```
///
/// And here is that user interaction type being called by a Destination's interface. Note that `performInterfaceAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.
/// ```swift
/// destination().handleThrowable {
///    try destination().performInterfaceAction(interactionType: .moreButton)
/// }
/// ```
///
/// > Important: This is an abstract protocol and Interactor objects should not conform to this directly. For Interactors running in a synchronous context where closures will provide operation results, please conform to ``SyncInteractable``. If you need your Interactor to run as an Actor in an async context, please conform to ``AsyncInteractable``. And if your Interactor needs to represent a datasource for model retrieval, please use the ``Datasourceable`` or ``AsyncDatasourceable`` based on the context it should run in.
public protocol Interactable<Request>: AnyObject {
    
    /// A configuration model which defines an interactor request.
    associatedtype Request: InteractorRequestConfiguring
    
}

/// A generic closure which provides a result to an Interactor request.
///
/// This closure is generally used with Interactors conforming to ``SyncInteractable``, which runs in a synchronous context. It provides both the result data and the original request object.
public typealias InteractorResponseClosure<Request: InteractorRequestConfiguring> = (_ result: Result<Request.ResultData, Error>, _ request: Request) -> Void
