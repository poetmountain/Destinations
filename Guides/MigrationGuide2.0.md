## Destinations 2.0 Migration Guide

Destinations 2.0 has many improvements to Interactors and general quality of life improvements. Though most of the API is relatively the same, there are several breaking changes and functional differences to be aware of. This guide is provided to help in the transition to 2.0 from prior versions.

### Notable Changes

* Any Requests for Interactors you have will need a `RequestContentType` typealias specified. This represents an enum which can be passed into the request as optional content.
* `DatasourceResponseClosure` has been renamed to `InteractorResponseClosure`.
* `InteractorRequestConfiguring`'s' ResultData associated type is now a `ContentTypeable` instead of a Hashable object. 
* The setup of Interactor assistants and Destination presentations has been automated when a Provider builds a Destination. Manually calling `buildPresentations()` and manually setting up Interactor assistants is no longer necessary within the Provider `buildDestination(...)` method.
* Most state properties on Destination classes have been moved to a new `DestinationInternalState` internal state object (as well as a secondary `GroupDestinationInternalState` state object for Destination classes conforming to `GroupedDestinationable`). Any properties that now exist in these state objects can be safely removed from your Destination classes. 
* As a side effect of the new internal state objects, these internal state properties can no longer be accessed directly from outside the Destination class, and so some convenience functions have been added. If you need to set the `parentDestinationID` of a child Destination, you can use the new `setParentID(id:)` method to do so. If you need to retrieve the `parentDestinationID` of a Destination, you can use the new `parentDestinationID()` method.
* `Datasourceable`'s `startItemsRetrieval()` method has been marked as deprecated, and will be removed in a future version. If you need to configure an Interactor prior to use, please use the new method `prepareForRequests()`. Typically you might want to call this from a Destination's `configureInteractor()` method.
* `Datasourceable`/`AsyncDatasourceable`'s `statusUpdate` delegate property has been removed. These properties can be safely removed from your datasources. Please use the new Destination methods `handleInteractorResult(result:, for:)` and `handleAsyncInteractorResult(result:, for:)` to handle the results of Interactor operations.
* There is a new abstract protocol for Interactors, `AbstractInteractable`. `Interactable` should now only be used as a protocol for Interactors operating in a synchronous context, and `AsyncInteractable` will continue to apply to async Interactors. If you need to iterate over a heterogenous mix of Interactors, use the `AbstractInteractable` protocol to do so.
* The `navigationController` type in the `DestinationPresentationType` enum has been renamed to `navigationStack`.
* The Destination method `setupInteractor` method has been renamed to `assignInteractor`.
