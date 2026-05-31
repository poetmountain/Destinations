## Destinations 3.0 Migration Guide

Destinations 3.0 provides increased navigation capabilities, more advanced usage options, as well as general quality of life improvements. Though most of the API is relatively the same, there are several breaking changes and functional differences to be aware of. This guide is provided to help in the transition to 3.0 from prior versions.

### Notable Changes

* Runtime checks have been added to Flow and Provider objects to determine if any Route types in a Flow do not have a Provider assigned to them, whether all user interactions have a presentation or interactor action assigned to them, as well as whether a `EventType` has been incorrectly assigned to both a presentation and an interactor action. If you run your project and receive an assert via these preflight checks, the error message will let you know what needs to be fixed.
* An `AutoCaseIterable` macro has been added to Destinations. It adds automatic conformance to the`CaseIterable` protocol to any enums you apply it to, even when an enum has cases with associated values. `RoutableDestinations` and `EventTypeable` protocols now require `CaseIterable` conformance, so adoption should be easier and eliminate the need to manually update an array of enum cases.
* There is no longer a need to pass in `actionType` to interactor assistant initializers, as the `actionType` property has been removed from the `InteractorAssisting` protocol. The `actionType` is now passed in internally to the assistant via `handleRequest()` and `handleAsyncRequest()`. The `actionType` property in your Interactors and any assignments in their initializers may be safely removed.
* `Destinationable`'s  `performInterfaceAction` method has been renamed to `performAction`. `performInterfaceAction` has been marked as deprecated and will be removed in a future version. Please migrate your code to use the `performAction(for:content:)` method instead.
* In previous versions the `moveToNearest` presentation type had an associated value that defined the Destination type to move to. This has been removed and the type is now defined by the `DestinationPresentation`'s `destinationType` property.
* The deprecated `assignRoot(rootController:)` method on `ControllerFlowable` has been removed. If you are still using this method, please use the new `assignBaseController(_:)` method instead.
* `Datasourceable`'s deprecated `startItemsRetrieval()` method has now been removed. If you are still using this method, please use the new method `prepareForRequests()`. Typically you might want to call this from a Destination's `configureInteractor()` method.

