//
//  ConfigurationError.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/31/25.
//

/// Configuration errors that may be detected at runtime.
public enum ConfigurationError: Error {
    
    /// File is not found.
    case missingFile(String, String, String)
    
    /// File is not JSON format.
    case missingJSON(String, String)
    
    /// Missing a type that belongs to the configuration.
    case missingType(String, String, String)
}

/// Returns a missingFile ConfigurationError with the specified message.
/// The source function, file and line are recorded in location.
public func missingFileError(_ fileName: String, _ bundlePath: String, source: String = #function, file: String = #file, line: Int = #line) -> Error {
    return ConfigurationError.missingFile(fileName, bundlePath, "Thrown in \(source) (File: \(file) Line: \(line))")
}

/// Returns a badJSON ConfigurationError with the specified message.
/// The source function, file and line are recorded in location.
public func missingJSONError(_ name: String, source: String = #function, file: String = #file, line: Int = #line) -> Error {
    return ConfigurationError.missingJSON(name, "Thrown in \(source) (File: \(file) Line: \(line))")
}

/// Returns a missingType ConfigurationError with the specified message.
/// The source function, file and line are recorded in location.
public func missingTypeError(_ kind: String, _ name: String, source: String = #function, file: String = #file, line: Int = #line) -> Error {
    return ConfigurationError.missingType(kind, name, "Thrown in \(source) (File: \(file) Line: \(line))")
}

extension ConfigurationError: CustomStringConvertible {
    
    private static let prefix = "Configuration error"

    /// Returns a description of the error, including the type, message,
    /// source function, file and line.
    public var description: String {
        switch self {
        case .missingFile(let fileName, let bundlePath, let location):
            return "\(Self.prefix): Missing file \(fileName) in bundle \(bundlePath)\n\(location)"
        case .missingJSON(let name, let location):
            return "\(Self.prefix): Missing \(name) in configuration file\n\(location)"
        case .missingType(let kind, let name, let location):
            return "\(Self.prefix): Could not resolve \(kind) named \(name)\n\(location)"
        }
    }
    
}
