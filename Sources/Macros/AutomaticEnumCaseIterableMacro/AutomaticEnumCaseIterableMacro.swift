import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// This macro provides automatic conformance of the `CaseIterable` protocol to enums, including those with associated values.
public struct AutomaticEnumCaseIterableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.addDiagnostics(from: MacroError.notAnEnum, node: node)
            return []
        }

        let cases = enumDecl.memberBlock.members.compactMap { member in
            member.decl.as(EnumCaseDeclSyntax.self)
        }

        var caseExpressions: [String] = []

        for caseDecl in cases {
            for element in caseDecl.elements {
                let caseName = element.name.text

                if let parameterClause = element.parameterClause {
                    let args = parameterClause.parameters.map { param in
                        let label = param.firstName?.text
                        let defaultValue = defaultValueForType(param.type)

                        if let label, label != "_" {
                            return "\(label): \(defaultValue)"
                        } else {
                            return defaultValue
                        }
                    }
                    caseExpressions.append(".\(caseName)(\(args.joined(separator: ", ")))")
                } else {
                    caseExpressions.append(".\(caseName)")
                }
            }
        }

        let allCasesArray = caseExpressions.map { "\($0)," }.joined(separator: "\n")

        let extensionDecl: DeclSyntax = """
            extension \(type.trimmed): CaseIterable {
                public static var allCases: [\(type.trimmed)] {
                    [
            \(raw: allCasesArray)
                    ]
                }
            }
            """

        guard let extensionSyntax = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionSyntax]
    }

    private static func defaultValueForType(_ typeSyntax: TypeSyntax) -> String {
        // Handle Optional types (both T? and Optional<T> syntax)
        if typeSyntax.is(OptionalTypeSyntax.self) {
            return "nil"
        }

        // Handle Optional<T> generic syntax
        if let identifierType = typeSyntax.as(IdentifierTypeSyntax.self),
           identifierType.name.text == "Optional" {
            return "nil"
        }

        let typeName = typeSyntax.trimmedDescription

        switch typeName {
        case "Int", "Int8", "Int16", "Int32", "Int64",
             "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            return "0"
        case "Float", "Double", "CGFloat":
            return "0"
        case "String":
            return "\"\""
        case "Bool":
            return "false"
        case "Character":
            return "\"\\0\""
        default:
            return "\(typeName).init()"
        }
    }
}

enum MacroError: Error, CustomStringConvertible {
    case notAnEnum

    var description: String {
        switch self {
        case .notAnEnum:
            return "@AutomaticEnumCaseIterable can only be applied to enum types"
        }
    }
}

@main
struct AutomaticEnumCaseIterablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutomaticEnumCaseIterableMacro.self,
    ]
}

/// Adds a parameterless initializer to all `CaseIterable` types,
/// returning the first case. This allows the macro to generate
/// `TypeName.init()` uniformly for both structs and enums.
public extension CaseIterable {
    init(_caseIterableDefault: Void = ()) {
        self = Self.allCases[Self.allCases.startIndex]
    }
}
