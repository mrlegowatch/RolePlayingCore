//
//  JSONFile.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/15/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//


extension Bundle {
    
    /// Loads a specified JSON-formatted UTF-8 file from this bundle's resources, and returns its dictionary.
    ///
    /// - parameter fileName: The name of the file, without its extension.
    ///
    /// - throws: `ServiceError.runtimeError` if the file is missing, or can't be parsed into a dictionary.
    /// - throws: `NSError` if the file can't be read.
    public func loadJSON(_ fileName: String) throws -> Data {
        guard let url = self.url(forResource: fileName, withExtension: "json") else { throw RuntimeError("Could not load \(fileName).json from \(self.bundleURL)") }
        return try Data(contentsOf: url, options: [.mappedIfSafe])
    }
}
