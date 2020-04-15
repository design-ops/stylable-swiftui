//
//  Verbosity.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 15/04/2020.
//

import Foundation
import os


public final class Logger {

    public static let `default` = Logger()

    public var level: OSLogType

    init() {
        #if debug
            self.level = .default
        #else
            self.level = .error
        #endif
    }

    private func shouldLog(_ level: OSLogType) -> Bool {
        return self.level.rawValue <= level.rawValue
    }

    func log(_ items: Any..., separator: String = " ", level: OSLogType = .default) {
        guard self.shouldLog(level) else {
            return
        }

        let printString = items.map(String.init(describing:))
            .joined(separator: separator)

        os_log("%@", log: .default, type: level, printString)
    }
}
