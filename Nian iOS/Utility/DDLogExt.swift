//
//  DDLogExt.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/13/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import Foundation

extension DDLog {
    
    private struct State {
        static var logLevel: DDLogLevel = .Error
        static var logAsync: Bool = false
    }
    
    class var logLevel: DDLogLevel {
        get { return State.logLevel }
        set { State.logLevel = newValue }
    }
    
    class var logAsync: Bool {
        get { return (self.logLevel != .Error) && State.logAsync }
        set { State.logAsync = newValue }
    }
    
    class func log(flag: DDLogFlag, @autoclosure message:  () -> String,
        function: String = __FUNCTION__, file: String = __FILE__,  line: UInt = __LINE__) {
            if flag.rawValue & logLevel.rawValue != 0 {
                var logMsg = DDLogMessage(message: message(), level: logLevel, flag: flag, context: 0,
                    file: file, function: function, line: line,
                    tag: nil, options: DDLogMessageOptions(0), timestamp: nil)
                DDLog.log(logAsync, message: logMsg)
            }
    }
}

func logError(@autoclosure message:  () -> String, function: String = __FUNCTION__,
    file: String = __FILE__, line: UInt = __LINE__) {
        DDLog.log(.Error, message: message, function: function, file: file, line: line)
}

func logWarn(@autoclosure message:  () -> String, function: String = __FUNCTION__,
    file: String = __FILE__, line: UInt = __LINE__) {
        DDLog.log(.Warning, message: message, function: function, file: file, line: line)
}

func logInfo(@autoclosure message:  () -> String, function: String = __FUNCTION__,
    file: String = __FILE__, line: UInt = __LINE__) {
        DDLog.log(.Info, message: message, function: function, file: file, line: line)
}

func logDebug(@autoclosure message:  () -> String, function: String = __FUNCTION__,
    file: String = __FILE__, line: UInt = __LINE__) {
        DDLog.log(.Debug, message: message, function: function, file: file, line: line)
}

func logVerbose(@autoclosure message:  () -> String, function: String = __FUNCTION__,
    file: String = __FILE__, line: UInt = __LINE__) {
        DDLog.log(.Verbose, message: message, function: function, file: file, line: line)
}


class Formatter: DDDispatchQueueLogFormatter, DDLogFormatter {
    let threadUnsafeDateFormatter: NSDateFormatter
    
    override init() {
        threadUnsafeDateFormatter = NSDateFormatter()
        threadUnsafeDateFormatter.formatterBehavior = .Behavior10_4
        threadUnsafeDateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        super.init()
    }
    
    override func formatLogMessage(logMessage: DDLogMessage!) -> String {
        let dateAndTime = threadUnsafeDateFormatter.stringFromDate(logMessage.timestamp)
        
        var logLevel: String
        let logFlag = logMessage.flag
        if logFlag & .Error == .Error {
            logLevel = "E"
        } else if logFlag & .Warning == .Warning {
            logLevel = "W"
        } else if logFlag & .Info == .Info {
            logLevel = "I"
        } else if logFlag & .Debug == .Debug {
            logLevel = "D"
        } else if logFlag & .Verbose == .Verbose {
            logLevel = "V"
        } else {
            logLevel = "?"
        }
        
        let formattedLog = "\(dateAndTime) |\(logLevel)| [\(logMessage.fileName) \(logMessage.function)] #\(logMessage.line): \(logMessage.message)"
        
        return formattedLog;
    }
}
















