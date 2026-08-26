//
//  AssistantAssigning.swift
//  Destinations
//
//  Copyright © 2026 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import Foundation

/// A narrow, type-erased entry point for assigning an interactor assistant to a Destination.
///
/// This exists so callers holding `any InteractorConfiguring<InteractorType>` can dispatch the assignment without exposing the configuration's `Interactor` associated type (and the `Interactor.Request.ResultData == Destination.ContentType` constraint that would otherwise be required at the call site).
@MainActor public protocol AssistantAssigning {

    /// Attempts to assign an interactor assistant for the given event type.
    ///
    /// The implementation should runtime-check that `assistant` is a compatible `InteractorAssisting` for this destination's `InteractorType`/`ContentType` and that `eventType` matches its `EventType` before assigning.
    /// - Returns: `true` if the assignment succeeded, `false` if the types didn't match.
    @discardableResult
    func tryAssignInteractorAssistant(_ assistant: any Sendable, for eventType: any Hashable) -> Bool
}
