/// This macro provides conformance of the `CaseIterable` protocol to enums, including those with associated values.
///
/// In the example below, applying `@AutoCaseIterable` to this enum provides automatic `CaseIterable` conformance, even though these cases have associated values.
///
/// For associated values, default values are chosen in this order:
/// 1. A default value written on the case parameter (`case x(Foo = .bar)`) is used verbatim. This is the recommended way to handle nested enums and Swift types which have no default init() available, such as URL.
/// 2. Optional types use `nil`.
/// 3. Numeric types use `0`.
/// 4. String uses `""`.
/// 5. Bool uses `false`.
/// 6. Other types use `.init()` (works for structs whose properties are all Optional or have default values).
///
///    Usage:
///
///        @AutoCaseIterable
///        enum InterfaceType {
///           case inputField(value: String)
///           case modeButton(mode: Mode)
///           case media(URL = URL(string: "https://apple.com")!)
///           case divider
///         }
///
@attached(extension, conformances: CaseIterable, names: named(allCases)) public macro AutoCaseIterable() = #externalMacro(module: "AutomaticEnumCaseIterableMacro", type: "AutomaticEnumCaseIterableMacro")

/// Adds a parameterless initializer to all `CaseIterable` types,
/// returning the first case. This allows the macro to generate
/// `TypeName.init()` uniformly for both structs and enums.
public extension CaseIterable {
    init(_caseIterableDefault: Void = ()) {
        self = Self.allCases[Self.allCases.startIndex]
    }
}
