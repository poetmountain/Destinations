//
//  PMLogger.swift
//  Destinations
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

/* WSLogger license
 The MIT License (MIT)

 Copyright (c) 2016 Whitesmith

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import OSLog

/// Severity of the log.
public enum PMLogLevel: Int {
    case none
    case error
    case warning
    case info
    case debug
    case verbose
}

public struct PMLoggerOptions {
    /// Determines the maximum level at which log entries are shown.
    /// For example, if the `level` is `debug` then all `verbose` entries will be ignored. The default value is `debug`.
    public var maximumOutputLevel = PMLogLevel.debug
}

public protocol PMLoggerCategoryTypes: CaseIterable & RawRepresentable where RawValue == String {
    
    func emojiRepresentation() -> String
}

/// Wrapper for OSLog to provide easy logging.
/// Based on WSLogger code: https://github.com/whitesmith/WSLogger
public final class PMLogger {

    internal var outputable: PMLoggerOutputable

    /// Determines whether to show the filename and line number on the log entry.
    public var shouldUseFileInfo: Bool = false
    
    /// Determines whether to show the class and function on the log entry.
    public var shouldUseMethodInfo: Bool = false

    /// Determines whether to show the timestamp of the log entry.
    public var shouldUseTimestamp: Bool = false

    /// Determines whether to show log entries.
    public var shouldOutputLogEntries = true
    
    private(set) var categories: any PMLoggerCategoryTypes.Type
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "hh:mm:ss.SSS"
        return df
    }()
    
    public var options = PMLoggerOptions()
    
    init(customOutput: PMLoggerOutputable? = nil) {
        
        self.categories = DestinationsLoggerCategories.self
        
        if let customOutput {
            self.outputable = customOutput
        } else {
            self.outputable = PMOSLogOutput()
        }

    }

    /// Log locally
    @discardableResult
    public func log(_ message: String, category: DestinationsLoggerCategories = .destinations, level: PMLogLevel = .debug, customAttributes: [String : Any]? = nil, customAttributesSortBy: ((String, String) throws -> Bool)? = nil, className: String = "", fileName: NSString = #file, line: Int = #line, function: String = #function) -> String {
        guard
            logAllowed(level, className: className)
        else {
            return "" //ignore
        }

        var logInfo = ""
        if shouldUseFileInfo {
            logInfo += fileName.lastPathComponent + ":" + String(line) + " "
        }
        if shouldUseMethodInfo {
            logInfo += className.isEmpty ? function : className + "." + function
        }
        
        if !logInfo.isEmpty {
            logInfo = "▫️\(logInfo)▫️"
        }

        var timestampInfo = ""
        if shouldUseTimestamp {
            timestampInfo = dateFormatter.string(from: Date.now)
        }

        var customAttributesText = ""
        if let customAttributes = customAttributes, !customAttributes.isEmpty {
            let sortedCustomAttributes = customAttributesSortBy == nil ? customAttributes.keys.sorted() : try! customAttributes.keys.sorted(by: customAttributesSortBy!)
            customAttributesText = "["
            customAttributesText += sortedCustomAttributes.map({ key in
                return "\(key): \(customAttributes[key]!)"
            }).joined(separator: ", ")
            customAttributesText += "]"
        }
        
        let emoji = category.emojiRepresentation()
        
        let text = "\(timestampInfo) \(emoji)\(logInfo) \(message) \(customAttributesText)"
        outputable.log(text, level: level, category: category.rawValue)
        return text
    }

    /// Reset logger settings.
    func reset() {
        shouldUseFileInfo = true
        shouldUseMethodInfo = true
    }

    fileprivate func logAllowed(_ level: PMLogLevel, className: String) -> Bool {
        return shouldOutputLogEntries && level != .none && level.rawValue <= options.maximumOutputLevel.rawValue
    }

}

public protocol PMLoggerOutputable {
    func log(_ message: String, level: PMLogLevel, category: String)
}


@available(iOS 14.0, macOS 10.10, macCatalyst 13.0, tvOS 14.0, watchOS 7.0, *)
private class PMOSLogOutput: PMLoggerOutputable {

    private var loggers: [String: Logger] = [:]

    func getLogger(category: String) -> Logger {
        if let existingLogger = loggers[category] {
            return existingLogger
        }
        else {
            let newLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
            loggers[category] = newLogger
            return newLogger
        }
    }

    func log(_ message: String, level: PMLogLevel, category: String) {
        let oslogger = getLogger(category: category.lowercased())
        switch (level) {
        case .none:
            break
        case .debug:
            oslogger.debug("\(message)")
        case .error:
            oslogger.critical("\(message)")
        case .warning:
            oslogger.warning("\(message)")
        case .info:
            oslogger.info("\(message)")
        case .verbose:
            oslogger.trace("\(message)")
        }
    }

}

public enum DestinationsLoggerCategories: String, PMLoggerCategoryTypes, CaseIterable {
    case destinations
    case network
    case ui
    case testing
    case error
    
    public func emojiRepresentation() -> String {
        
        var emoji = ""
        
        switch self {
            case .network:
                emoji = "🛜"
            case .ui:
                emoji = "✏️"
            case .destinations:
                emoji = "📍"
            case .testing:
                emoji = "🔬"
            case .error:
                emoji = "📍 ⚠️"
        }
        
        return emoji
    }
}
