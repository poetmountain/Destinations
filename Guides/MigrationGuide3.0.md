## Destinations 3.0/3.1 Migration Guide

Destinations 3.0 provides increased navigation capabilities, more advanced usage options, as well as general quality of life improvements. Though most of the API is relatively the same, there are several breaking changes and functional differences to be aware of. This guide is provided to help in the transition to 3.0 from prior versions.

Destinations 3.1 creates a new state model type to move business logic and interactor handling out of Destination objects. This allows state objects to be easy to swap out as well as removing the need to create custom Destinations in most cases. This is a breaking change and this decision was not made lightly, but will allow Destinations to more fully fulfill its promise of decoupling user interfaces from their logic.


### Notable Changes

#### 3.0

* Runtime checks have been added to Flow and Provider objects to determine if any Route types in a Flow do not have a Provider assigned to them, whether all user interactions have a presentation or interactor action assigned to them, as well as whether a `EventType` has been incorrectly assigned to both a presentation and an interactor action. If you run your project and receive an assert via these preflight checks, the error message will let you know what needs to be fixed.
* An `AutoCaseIterable` macro has been added to Destinations. It adds automatic conformance to the`CaseIterable` protocol to any enums you apply it to, even when an enum has cases with associated values. `RoutableDestinations` and `EventTypeable` protocols now require `CaseIterable` conformance, so adoption should be easier and eliminate the need to manually update an array of enum cases.
* There is no longer a need to pass in `actionType` to interactor assistant initializers, as the `actionType` property has been removed from the `InteractorAssisting` protocol. The `actionType` is now passed in internally to the assistant via `handleRequest()` and `handleAsyncRequest()`. The `actionType` property in your Interactors and any assignments in their initializers may be safely removed.
* `Destinationable`'s  `performInterfaceAction` method has been renamed to `performAction`. `performInterfaceAction` has been marked as deprecated and will be removed in a future version. Please migrate your code to use the `performAction(for:content:)` method instead.
* In previous versions the `moveToNearest` presentation type had an associated value that defined the Destination type to move to. This has been removed and the type is now defined by the `DestinationPresentation`'s `destinationType` property.
* The deprecated `assignRoot(rootController:)` method on `ControllerFlowable` has been removed. If you are still using this method, please use the new `assignBaseController(_:)` method instead.
* `Datasourceable`'s deprecated `startItemsRetrieval()` method has now been removed. If you are still using this method, please use the new method `prepareForRequests()`. Typically you might want to call this from a Destination's `configureInteractor()` method.

#### 3.1

* The `destinationState` object in your user interfaces now requires a new `stateModel` property, which will become the location where view state and business logic lives. Please see the User Guide and updated example projects to understand how these state models work in the Destinations ecosystem.
* Most of the Destinationable methods you previously implemented directly on a Destination class — `prepareForPresentation`, `prepareForAppearance(isVisible:)`, `prepareForDisappearance(wasVisible:)`, `handleEvent(_:content:)`, `handleInteractorResult(result:for:)`, `handleAsyncInteractorResult(result:for:)`, `configureInteractor(_:type:)`, and `cleanupResources()` — are now forwarded from the Destination to its state model, so you can and should migrate those methods to the state model. In most cases doing so will allow you completely get rid of your custom Destination classes and replace them with the generic `ViewDestination` or `ControllerDestination` classes that Destinations provides.
* `UserInteractionType` has been renamed to `EventType` everywhere in Destinations. This conceptual change was made to better generalize this type, as events can be triggered from user interactions, but also via the state model's logic. There were too many similarly-named concepts, such as user interactions, actions, and interactors. Renaming to `EventType` increases clarity without reducing comprehension, as events are a well-understood concept.
