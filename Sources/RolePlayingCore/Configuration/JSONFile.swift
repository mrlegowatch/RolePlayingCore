//
//  JSONFile.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/15/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// Loads a specified JSON-formatted UTF-8 file from this bundle's resources, and returns its dictionary.
    ///
    /// - parameter fileName: The name of the file, without its extension.
    /// - parameter source: The name of the calling function. Defaults to `#function`.
    /// - parameter file: The name of the file where the error occurred. Defaults to `#file`.
    /// - parameter line: The line number where the error occurred. Defaults to `#line`.
    ///
    /// - throws: `ConfigurationError.missingFile` if the file is missing.
    /// - throws: `NSError` if the file can't be read.
    public func loadJSON(_ fileName: String, source: String = #function, file: String = #file, line: Int = #line) throws -> Data {
        guard let url = self.url(forResource: fileName, withExtension: "json") else { throw missingFileError("\(fileName).json", "\(self.bundleURL)", source: source, file: file, line: line) }
        return try Data(contentsOf: url, options: [.mappedIfSafe])
    }
}
