//
//  Interactable.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This protocol represents an Interactor object. Interactors provide an interface to perform some business logic, often acting as a datasource by interfacing with an API, handling system APIs, or some other self-contained work.
///
///  The concept of Interactors comes from [Clean Swift](https://clean-swift.com), used in its architecture as a way to move logic and datasource management out of view controllers. In Destinations, the `Interactable` protocol represents Interactor objects which provide an interface to perform some logic or data request, typically by interfacing with an backend API, handling system APIs, or some other self-contained work. `Datasourceable` inherits from this protocol and should be used for objects which specifically represent a datasource of some kind. There are also Actor-based async versions of these protocols available.
///
///  Though requests to Interactors can be made using a Destination's `performRequest` method, in general one should use the `performInterfaceAction` method. This abstracts the specific implementation details of an interactor away from the interface and lets it focus on making requests through a standardized request.
///
///  The recommended way is to assign a user interaction type to your request and using an `InteractorAssisting`-conforming assistant to configure the request, leaving the Destination's interface free of associated business logic.
///
///  Interactors are typically created by Destination providers and stored in the Destination. Like with presentations of new Destinations, Interactor requests are associated with a particular `InterfaceAction` object and are represented by an `InteractorConfiguration` model object. Action types for each Interactor are defined as enums, keeping Interactor-specific knowledge out of the interface.
///
///  Here the configuration model for the interface action is being assigned to a "moreButton" user interaction type when the Destination's provider is created:
///  ```swift
///  let moreButtonConfiguration = InteractorConfiguration<ColorsListProvider.InteractorType, ColorsDatasource>(interactorType: .colors, actionType: .paginate)
///  let colorsListProvider = ColorsListProvider(presentationsData: [.color: colorSelection],
///                                              interactorsData: [.moreButton: moreButtonConfiguration])
///  ```
///
/// And here is that user interaction type being called a Destination's interface after a user's tap on a UI element. Note that `performInterfaceAction` can throw and the Destination method `handleThrowable` automatically handles that for you, logging any errors to the console with the built-in Logger class.
/// ```swift
/// destination().handleThrowable { [weak self] in
///    try self?.destination().performInterfaceAction(interactionType: .moreButton)
/// }
/// ```
///
/// If it's necessary, you can always make a request to a Destination's Interactor directly:
/// ```swift
/// Task {
///    let request = ColorsRequest(action: .paginate, numColorsToRetrieve: 5)
///
///    let result = await destination().performRequest(interactor: .colors, request: request)
///    await handleColorsResult(result: result)
/// }
///```
public protocol Interactable<Request>: AnyObject {
    

    /// A configuration model which defines an interactor request.
    associatedtype Request: InteractorRequestConfiguring
    
    /// The type of data that is returned from a datasource.
    associatedtype ResultData: ContentTypeable
    
    associatedtype ActionType: InteractorRequestActionTypeable
    
    /// A content model type which this interactor returns.
    associatedtype Item: Hashable

}

/// Generic closure to handle data source responses.
public typealias InteractorResponseClosure<Request: InteractorRequestConfiguring> = (_ result: Result<Request.ResultData, Error>, _ request: Request) -> Void
