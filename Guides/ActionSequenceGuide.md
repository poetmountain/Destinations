# Action Sequences

Action sequences are a powerful way to encapsulate a complex series of async Interactor requests and perform them as a single action which participates in Swift's async/await concurrency environment. Where a single `InteractorConfiguration` maps one event to one request, action sequences describe a series of linear steps such as an API request, background processing, or other self-contained work as a graph that runs end-to-end in a managed Swift concurrency task. A sequence step can represent a single `Action`, a group of requests running in parallel in a TaskGroup with `ActionGroup`, or a branch that forks to one of several paths based on condition objects.

What makes this powerful is that all sequence step types conform to `ActionPerformable`, and both `ActionSequence` and `ActionGroup` accept arrays of `ActionPerformable` objects. This means that you could have a sequence with several groups in series, a group of child sequences, or even a group of child groups, and nest them as much as you want to create complex and branching "recipes" of tasks.

Instead of instantiating Action Sequence classes directly, you build the sequence declaratively using configuration object chains. There are four main building blocks when assembling a sequence configuration:

**`ActionConfiguration`**: A step that handles a single Interactor action type.  
**`ActionSequenceConfiguration`**: An ordered pipeline of steps that run one after the other.  
**`ActionGroupConfiguration`**: A step that runs multiple child actions concurrently, then merges their results into one value.  
**`ActionBranchConfiguration`**: A step that evaluates conditions at runtime and runs the first matching path.

## Building a Sequence

This is the basic flow in an Action Sequence. Output conduits are the glue between each sequence step, passing the output from the previous Action and transforming it with a Transformer object to a format that the next sequence step expects, before passing it on.

[Action] -> [Output Conduit] -> [Transformer] -> [Action]

### Sequence Steps

Each step in a sequence is represented by an `ActionConfiguration` object. It names the Interactor to call, the Interactor's action to perform, and the Interactor assistant to use.

```swift
let fetchStep = ActionConfiguration<AppInteractorType, AppContentType, NotesDatasource>(
    interactorType: .notes,
    action: .retrieve,
    assistant: .basicAsync,
    identifier: StepType.fetch)
```

The `identifier` is optional but recommended when you want to look up a specific step's result afterward. It can be any type that conforms to `ActionIdentifying`, but an enum case is the recommended choice.

When you need custom logic in a step's request — for example, attaching specific parameters from the content flowing in — pass a custom assistant via `.custom(...)`:

```swift
let saveStep = ActionConfiguration<AppInteractorType, AppContentType, NotesDatasource>(
    interactorType: .notes,
    action: .save,
    assistant: .custom(NotesAssistant()),
    identifier: StepType.save)
```

### Chaining Steps

An action sequence is represented by an `ActionSequenceConfiguration` object. This object offers a chainable `.step()` method that allows you to attach step configuration objects, with the chain's sequence mirroring the order in which the sequence will run. 

Attach a conduit by calling `.output()` immediately after the step it belongs to:

```swift
let config = try ActionSequenceConfiguration<AppInteractorType, AppContentType>()
    .step(fetchStep)
    .output()
    .step(processStep)
    .output()
    .step(saveStep)
```

The last step has no `.output()` call — there's nowhere to send its result.

## Passing Results Between Steps

Every sequence step except the last must have an output conduit attached using the `.output()` chain method; `.step()` throws an `ActionError.missingConduit` error at build time if you try to append a step without one. The `.output()` method attaches an `ActionSequenceConduit` that forwards a step's output content directly to the next step. When the content shape needs to change between steps — say, a raw image download that needs to be wrapped in a file model before the save step can use it — supply a transformer:

```swift
.output(using: ImageToFileTransformer())
```

Transformers conform to `ContentTransformable`, which requires a single `transform(input:) throws -> ContentType` method:

```swift
struct ImageToFileTransformer: ContentTransformable {
    typealias ContentType = AppContentType

    func transform(input: AppContentType) throws -> AppContentType {
        guard case .image(let image) = input else {
            throw SequenceError.unexpectedContent
        }
        return .imageFile(ImageFile(data: image.pngData()!))
    }
}
```

If the transformer throws, the sequence fails immediately with that error, propagating it through the `.failure` result.

## Groups

An `ActionGroup` is an `ActionPerformableCollection` conforming type which runs multiple child actions concurrently via a Swift `TaskGroup`. Because it conforms to `ActionPerformable` it may be used as a sequence step, inside another group, or act as a top-level action collection. You should not instantiate an `ActionGroup` directly. Instead you should create an ``ActionGroupConfiguration`` object to define it, and used in conjunction with ``Destinationable/performActions(configuration:content:)-1nsw5``.

```swift
let steps: [any ActionConfiguring<AppInteractorType, AppContentType>] = [stepA, stepB, stepC]

let group = ActionGroupConfiguration<AppInteractorType, AppContentType>(
    actions: steps,
    merger: MyResultsMerger(),
    identifier: StepType.parallelGroup)
```

### Child failure behavior

Each child's `shouldEndParentTaskOnFailure` flag controls what happens when that child fails:

 - **`true`**: The group immediately calls `cancelAll()` on its remaining siblings, builds a group-level ``ActionResult`` containing all results collected up to that point plus the failing child's failure result, and returns ``ActionError/cancelled(partialResults:)``. Siblings that had not yet completed are cancelled.

 - **`false`**: The group records the failure and lets all remaining siblings run to completion. Once every child has finished, the group builds a single group-level ``ActionResult`` whose `origin` property includes child results for every task's success or failure, then returns ``ActionError/cancelled(partialResults:)``. The merger is not called because not all children succeeded.
 
### Passing the results

When all of an `ActionGroup`'s children finish their actions, a merger object combines their individual results into a single content value that is passed to the next step. The group passes this content value and all of the group's child results via a single ``ActionResult``, and passes the merged value on through its output conduit. The merger conforms to `ActionResultsMerging`, which provides one method that receives an `ActionCollectionResults` containing the children's outputs and returns a single merged content value:

```swift
struct MyResultsMerger: ActionResultsMerging {
    typealias ContentType = AppContentType

    func merge(results: ActionCollectionResults<ContentType>) -> ContentType? {
        let allItems = results.results.compactMap { result -> [MyItem]? in
            guard case .items(let items) = result.content else { return nil }
            return items
        }.flatMap { $0 }
        return .items(allItems)
    }
}
```

## Branching Paths

An `ActionBranch` is an `ActionPerformable` conforming type which selects and runs one of several actions based on provided conditions, evaluated against the current content and previous results in a sequence and runs the first path whose conditions return `true`. Branches are mainly only used as a step in an ``ActionSequence``.

`ActionBranch` evaluates its ``BranchConditionable`` conditions in declaration order and runs the first path whose condition (or conditions, if a group condition like ``AllSatisfyCondition`` or ``AnySatisfyCondition`` is used) returns `true`. If no condition matches and there's no fallback action, the branch fails with ``ActionError/cancelled(partialResults:)``. To guarantee a fallback path, you can add on an `.otherwise` path at the end of the branch chain. After the selected path action completes, `ActionBranch` applies the path's optional transformer to the result and forwards the content through its own output conduit to the next sequence step, recording one ``ActionResult`` with origin ``ActionResponseOrigin/branch``.

In the example below, if there are images passed-in from the previous step, it will process the images with a filter. If instead the content is text, it will render the text into an image. If neither was provided, it will choose the fallback action.

```swift
let branch = ActionBranchConfiguration<AppInteractorType, AppContentType>()
    .branch(when: HasImagesCondition(), action: processImageStep)
    .branch(when: HasTextCondition(),   action: renderTextStep)
    .otherwise(fallbackAction)

let config = try ActionSequenceConfiguration<AppInteractorType, AppContentType>()
    .step(branch)
    .output()
    .step(nextStep)
```

### Fallback Behavior

To provide a fallback action that runs in the case that no branch conditions match, you can add an `.otherwise(_:)` step at the end of the branch chain. Two built-in convenience chain methods cover the most common fallback patterns:

```swift
.otherwise(.skip)   // sequence continues; branch contributes no result
.otherwise(.fail)   // sequence stops and returns partial results as a failure
```

### Per-Path Transformers

Each branch path accepts an optional transformer that transforms the output of its action before it exits the branch. This is useful when different paths return different content types and the next sequence step expects a consistent type:

```swift
ActionBranchConfiguration<AppInteractorType, AppContentType>()
    .branch(when: HasImagesCondition(), action: imageStep, transformer: DataToImageTransformer())
    .branch(when: HasBackupImageCondition(), action: retrieveBackup)
    .otherwise(.skip)
```

### Conditions

Three built-in condition types ship with Destinations:

**`BooleanCondition`** tests a single `Bool` value. The condition passes when the value is `true`. Chaining `.negated()` on it turns the value expectation to `false` for the condition to pass.
```swift
BooleanCondition(isOnline)           // returns true when isOnline == true
BooleanCondition(isOnline).negated() // returns true when isOnline == false
```

**`AllSatisfyCondition`** takes an array of conditions and passes when all of them pass (logical AND):
```swift
AllSatisfyCondition(conditions: [IsOnlineCondition(), HasImagesCondition()])
```

**`AnySatisfyCondition`** takes an array of conditions and passes when at least one of the conditions passes (logical OR):
```swift
AnySatisfyCondition(conditions: [IsOnlineCondition(), HasCachedDataCondition()])
```

All condition types support the `.negated()` chain method, returning a `NegatedCondition` that passes whenever the original wouldn't:

```swift
IsOnlineCondition().negated() // passes when offline
```

### Custom Conditions

To create your own custom condition, implement `BranchConditionable` and evaluate the branch's incoming content:

```swift
struct HasImagesCondition: BranchConditionable {
    typealias ContentType = AppContentType

    func evaluate(content: AppContentType?) -> Bool {
        guard case .images(let images) = content else { return false }
        return !images.isEmpty
    }
}
```

Like the built-in condition classes, your custom conditions automatically support `.negated()` and are composable with `AllSatisfyCondition` and `AnySatisfyCondition`.

## Registering Interactors

`ActionSequenceConfiguration` objects can be registered at Provider build-time and tied to a specific Event, just like regular Interactor requests, which allows the built-in preflight checks to verify that each Interactor used is attached to the Destination. However `ActionSequenceConfiguration`s can also be built at runtime and passed directly via `performActions(configuration: content:)` without an assigned Event. This means that they do not get the same safety check until they are run. If any are missing, `performActions(...)` returns `DestinationsError.interactorNotFound` immediately (before any steps are run), so you'll get an early fail rather than a mid-sequence failure. Still, calling action sequences at runtime is inherently less safe due to this, so be sure to assign the Interactors you want to use in the Provider.

## Running a Sequence

There's two ways to run an action sequence. Both variants of the `performActions` method are `async` and returns a `Result` once the whole pipeline finishes (or fails). 

The first way is to assign a `ActionSequenceConfiguration` or `ActionGroupConfiguration` to an Event in a Provider's `interactorsData` dictionary (they both conform to `InteractorConfiguring`), and then call it `performActions(for:content:)` on a Destination. The optional `content` parameter seeds the first step with initial data.

```swift
let result = await destination.performActions(for: .retrievalEvent, content: nil)
```

The second way is by creating an `ActionSequenceConfiguration` at runtime and passed directly into `performActions(configuration: content:)`. This allows you to create the sequence steps dynamically and avoids having to create a new Event type for every action sequence you wish to run. The optional `content` parameter seeds the first step with initial data.

```swift
let result = await destination.performActions(configuration: config, content: nil)
```

## Cancellation

The sequence runs inside a Swift structured `Task`. `ActionSequence` and `ActionGroup` support Task cancellation. If you save a reference to the enclosing Task you can call `cancel()` on it to cancel the in-progress sequence. A good place to call this is in the state model's `cleanupResources()` method, which will be called the model's Destination is removed the Flow.

```swift
var sequenceTask: Task<Void, Never>?

sequenceTask = Task { [weak destination] in
    let result = await destination?.performActions(configuration: sequenceActions)
    ...
}

// Call to cancel mid-sequence
sequenceTask?.cancel()
```

In the case that a sequence is cancelled, it returns an `ActionError.cancelled` error with an `ActionCollectionResults` object containing all action results prior to the cancellation:

```swift
case .failure(let error):
    if case ActionError<ContentType>.cancelled(partialResults: let partialResults) = error {
        let completedSteps = partialResults.results.compactMap { $0.content?.rawValue }.joined(separator: ", ")
    }
```

## Reading Results

On success, `performActions` returns `ActionCollectionResults<ContentType>` which contains an array of `ActionResult` values representing every action run in the sequence, with the results in order that they were performed. An `ActionResult` is generated for any action that is performed, regardless of whether it succeeds or fails. A step which is an `ActionGroup` contributes a single result whose `.origin` is `.group(results:)`, which carries the individual child results inside it.

You can look up a specific step's result with the `last(identifier:)` method. The identifier is what you associated to its configuration object. What's returned is an `ActionResult` object containing the Result object from that action containing either the output content or an Error, as well as metadata like the origin and any child results.

```swift
if let saveResult = outputs.last(identifier: StepType.save) {
    let savedContent = saveResult.content
}
```

To collect every result with a given identifier (useful when the same identifier appears across parallel group children):

```swift
let allFetchResults = outputs.results(matching: StepType.fetch)
```

## Error Handling

If a sequence step fails and its `shouldEndParentTaskOnFailure` flag is `true`, or if a Transformer or Merger object fails, the sequence stops immediately and returns a Result `.failure` with an `ActionError.failed(partialResults:error:)` error containing the results of any steps that completed before the failure, as well as the specific Error which triggered the failure:

```swift
let result = await destination.performActions(configuration: config)

switch result {
    case .success(let results):
        // ...
    case .failure(let error):
        if case ActionError.failed(partialResults: let partial, error: let failureError) = error {
            print("Sequence failed after \(partial.results.count) completed step(s) due to \(failureError).")
            let completedSteps = partial.results.map { "\($0.origin)" }.joined(separator: ", ")
            print("Completed: \(completedSteps)")
        }
}
```

## Further information

Please see the **[ActionSequence demo project](../Examples/SwiftUI/ActionSequence/)** for a complete example, showing off action collections and branching in a pragmatic use case.
