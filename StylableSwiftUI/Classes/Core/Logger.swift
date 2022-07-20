//
//  Verbosity.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 15/04/2020.
//

import Foundation
import os

public final class Logger {

    // Logging level. Given the raw values of OSLogType I'm not sure I trust it enough.
    public enum Level: Int {
        case `default` = 0
        case info = 1
        case debug = 2
        case error = 3
        case fault = 4

        fileprivate var osLogType: OSLogType {
            switch self {
            case .default: return .default
            case .debug: return .debug
            case .info: return .info
            case .error: return .error
            case .fault: return .fault
            }
        }
    }

    public static let `default` = Logger()

    public var level: Level

    init() {
        #if debug
            self.level = .default
        #else
            self.level = .error
        #endif

//        print(OSLogType.fault.rawValue) // 17
//        print(OSLogType.error.rawValue) // 16
//        print(OSLogType.debug.rawValue) // 2
//        print(OSLogType.info.rawValue) // 1
//        print(OSLogType.default.rawValue) // 0
    }

    private func shouldLog(_ level: Level) -> Bool {
        return self.level.rawValue <= level.rawValue
    }

    private func log(_ items: [Any], separator: String = " ", level: Level = .default) {
        guard self.shouldLog(level) else {
            return
        }

        let printString = items.map(String.init(describing:))
            .joined(separator: separator)

        os_log("%@", log: .default, type: level.osLogType, printString)
    }

    func log(_ items: Any..., separator: String = " ", level: Level = .default) {
        self.log(items, separator: separator, level: level)
    }

    func info(_ items: Any, separator: String = " ") {
        self.log(items, separator: separator, level: .info)
    }

    func debug(_ items: Any, separator: String = " ") {
        self.log(items, separator: separator, level: .debug)
    }

    func error(_ items: Any, separator: String = " ") {
        self.log(items, separator: separator, level: .error)
    }

    func fault(_ items: Any, separator: String = " ") {
        self.log(items, separator: separator, level: .fault)
    }
}
