//
//  ActionCollectionResults.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// This object contains results of the actions which completed in an ``ActionPerformableCollection``, in the order they ran, with one result per sequence step or group.
@MainActor public struct ActionCollectionResults<ContentType: ContentTypeable>: Sendable {

    /// The results of each action which completed in the sequence, in the order they ran. A group step contributes a single ``ActionResult`` whose ``ActionResponseSource/group(results:)`` origin holds its child results.
    public private(set) var results: [ActionResult<ContentType>] = []

    /// Appends a result to the sequence's results. Generally this method is used by ``ActionGroup`` to add a merged result.
    /// - Parameter result: The result of the action to add.
    public mutating func add(_ result: ActionResult<ContentType>) {
        let identifierString = identifierString(for: result.identifier)

        DestinationsSupport.logger.log("🔗 Adding sequence step result with \(identifierString) with content \(result.origin)", level: .verbose)
        results.append(result)
    }

    /// Appends the result for a single Interactor action step.
    /// - Parameters:
    ///   - content: The content returned by the action.
    ///   - action: The action type of the Interactor request.
    ///   - identifier: An optional identifier of the step which produced this result.
    public mutating func addResult(result: Result<ContentType, Error>, for action: any InteractorRequestActionTypeable, identifier: (any ActionIdentifying)? = nil, shouldSaveResult: Bool) {        
        results.append(ActionResult(identifier: identifier, origin: .action(action), result: result))
    }

    /// Returns all results that match the specified identifier, searching group child results as well.
    /// - Parameter identifier: The step identifier to search for.
    /// - Returns: The matching responses, or an empty array if none were found.
    public func results(matching identifier: some ActionIdentifying) -> [ActionResult<ContentType>] {
        var matches: [ActionResult<ContentType>] = []
        for result in results {
            collectResults(in: result, identifier: identifier, into: &matches)
        }
        return matches
    }
    
    /// Returns the last top-level result in the sequence that matches the specified identifier.
    ///
    /// Unlike ``results(matching:)``, this method only searches the top-level results and does not recurse into group child results.
    ///
    /// - Parameter identifier: The step identifier to search for.
    /// - Returns: The last matching result, or `nil` if no match was found.
    public func last(identifier: some ActionIdentifying) -> ActionResult<ContentType>? {
        results.last(where: { $0.identifier.map(\.hashValue) == identifier.hashValue })
    }
    
    /// Returns all top-level results from the sequence that represent failed actions.
    ///
    /// Only top-level results are searched; group child results are not recursed into.
    ///
    /// - Returns: An array of ``ActionResult`` values whose result is a `.failure`, or an empty array if all actions succeeded.
    public func failedActions() -> [ActionResult<ContentType>] {
        return results.filter {
            if case .failure = $0.result { return true }
            return false
        }
    }

    private func collectResults(in result: ActionResult<ContentType>, identifier: some ActionIdentifying, into matches: inout [ActionResult<ContentType>]) {
        if let resultType = result.identifier, AnyHashable(resultType) == AnyHashable(identifier) {
            matches.append(result)
        }
        if case .group(let childResults) = result.origin, let childResults {
            for childResult in childResults {
                collectResults(in: childResult, identifier: identifier, into: &matches)
            }
        }
    }
    
    private func identifierString(for identifier: (any ActionIdentifying)?) -> String {
        if let identifier {
            "identifier \(identifier)"
        } else {
            "no identifier"
        }
    }
}
