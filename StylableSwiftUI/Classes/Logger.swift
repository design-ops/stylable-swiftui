//
//  Verbosity.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 15/04/2020.
//

import Foundation

public final class Logger {

    public static let `default` = Logger()

    public var level: Level

    public enum Level: Int {
        case debug = 0
        case info
        case warning
        case error
    }

    public init() {
        #if debug
            self.level = .info
        #else
            self.level = .warning
        #endif
    }

    private func shouldLog(_ level: Level) -> Bool {
        return self.level.rawValue <= level.rawValue
    }

    public func log(_ items: Any..., separator: String = " ", terminator: String = "\n", level: Level = .info) {
        guard self.shouldLog(level) else {
            return
        }

        let printString = items.map { "\($0)" }.joined(separator: separator)
        print(printString, terminator: terminator)
    }
}
