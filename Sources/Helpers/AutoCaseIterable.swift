/// This macro provides conformance of the `CaseIterable` protocol to enums, including those with associated values.
///
/// In the example below, applying `@AutoCaseIterable` to this enum provides automatic `CaseIterable` conformance, even though these cases have associated values.
///
///     @AutoCaseIterable
///     enum UserInteractions: UserInteractionTypeable {
///        case sliderInteraction(value: Double)
///        case modeButton(mode: Mode)
///      }
///
@attached(extension, conformances: CaseIterable, names: named(allCases)) public macro AutoCaseIterable() = #externalMacro(module: "AutomaticEnumCaseIterableMacro", type: "AutomaticEnumCaseIterableMacro")
