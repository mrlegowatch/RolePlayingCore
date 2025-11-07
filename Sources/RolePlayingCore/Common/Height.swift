//
//  Height
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A measurement of length.
public typealias Height = Measurement<UnitLength>

extension String {
    
    /// Parses ft or ', in or ", cm, m into a measurement of length.
    /// Returns nil if the string could not be parsed.
    public var parseHeight: Height? {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        
        // Try parsing imperial units (feet and/or inches)
        if let height = parseImperialHeight(from: trimmed) {
            return height
        }
        
        // Try parsing metric units
        if let height = parseMetricHeight(from: trimmed) {
            return height
        }
        
        // Try parsing as a plain number (default to feet)
        if let value = Double(trimmed) {
            return Height(value: value, unit: .feet)
        }
        
        return nil
    }
    
    private func parseImperialHeight(from string: String) -> Height? {
        let feetMarkers = ["'", "ft"]
        let inchesMarkers = ["\"", "in"]
        
        // Look for feet marker
        var feetValue: Double = 0
        var feetEndIndex = string.startIndex
        var foundFeet = false
        
        for marker in feetMarkers {
            if let range = string.range(of: marker) {
                let feetString = string[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
                guard let feet = Double(feetString) else { continue }
                feetValue = feet
                feetEndIndex = range.upperBound
                foundFeet = true
                break
            }
        }
        
        // Look for inches marker
        var inchesValue: Double = 0
        var foundInches = false
        
        for marker in inchesMarkers {
            if let range = string.range(of: marker) {
                let startIndex = foundFeet ? feetEndIndex : string.startIndex
                let inchesString = string[startIndex..<range.lowerBound].trimmingCharacters(in: .whitespaces)
                guard let inches = Double(inchesString) else { continue }
                inchesValue = inches
                foundInches = true
                break
            }
        }
        
        // Return nil if we didn't find any imperial markers
        guard foundFeet || foundInches else { return nil }
        
        // Convert everything to feet
        let totalInFeet = feetValue + Measurement(value: inchesValue, unit: UnitLength.inches).converted(to: .feet).value
        return Height(value: totalInFeet, unit: .feet)
    }
    
    private func parseMetricHeight(from string: String) -> Height? {
        let metricUnits: [(marker: String, unit: UnitLength)] = [
            ("cm", .centimeters),
            ("m", .meters)
        ]
        
        for (marker, unit) in metricUnits {
            if let range = string.range(of: marker) {
                let valueString = string[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
                guard let value = Double(valueString) else { continue }
                return Height(value: value, unit: unit)
            }
        }
        
        return nil
    }
}

public extension KeyedDecodingContainer  {
    
    /// Decodes either a number or a string into a Height.
    ///
    /// - throws `DecodingError.dataCorrupted` if the height could not be decoded.
    func decode(_ type: Height.Type, forKey key: K) throws -> Height {
        let height: Height?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            height = Height(value: double, unit: .feet)
        } else {
            height = try self.decode(String.self, forKey: key).parseHeight
        }
        
        // Throw if we were unsuccessful parsing.
        guard let height else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Missing string or number for Height value")
            throw DecodingError.dataCorrupted(context)
        }
        
        return height
    }
    
    /// Decodes either a number or a string into a Height, if present.
    ///
    /// - throws `DecodingError.dataCorrupted` if the height could not be decoded.
    func decodeIfPresent(_ type: Height.Type, forKey key: K) throws -> Height? {
        let height: Height?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            height = Height(value: double, unit: .feet)
        } else if let string = try self.decodeIfPresent(String.self, forKey: key) {
            height = string.parseHeight
        } else {
            height = nil
        }
        
        return height
    }
}

extension Height {
    
    /// Returns a string representation of the height suitable for display.
    public var displayString: String {
        // Use feet and inches for imperial locales
        let totalInches = self.converted(to: .inches).value
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        
        let feetMeasurement = Measurement(value: Double(feet), unit: UnitLength.feet)
        let feetString = feetMeasurement.formatted(.measurement(width: .abbreviated))
        
        let inchesMeasurement = Measurement(value: Double(inches), unit: UnitLength.inches)
        let inchesString = inchesMeasurement.formatted(.measurement(width: .abbreviated))
        return "\(feetString), \(inchesString)"
    }
}
