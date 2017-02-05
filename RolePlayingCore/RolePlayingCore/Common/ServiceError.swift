//
//  ServiceError.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

/*
 TODO: Consider switching to Swift Foundation error types if they become available.
 
 In the meantime, define "std::exception"-style errors manually from Error protocol.
 */

public enum ServiceError: Error {
    
    /// Represents an error detected at runtime.
    case runtimeError(String, String)
    
}

/// Returns a ServiceError.runtimeError with the specified message.
/// The source function, file and line are recorded in location.
public func RuntimeError(_ message: String, source: String = #function, file: String = #file, line: Int = #line) -> ServiceError {
    return ServiceError.runtimeError(message, "Thrown in \(source) (File: \(file) Line: \(line))")
}

extension ServiceError: CustomStringConvertible {
    
    /// Returns a description of the error, including the type, message, 
    /// source function, file and line.
    public var description: String {
        switch self {
        case .runtimeError(let message, let location):
            return "Runtime error: \(message)\n\(location)"
        }
    }
    
}
