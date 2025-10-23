//
//  WeightParser.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Weight is a measurement of mass.
public typealias Weight = Measurement<UnitMass>

extension String {
    
    /// Parses "lb" or "kg" into a measurement of mass.
    public var parseWeight: Weight? {
        var value: Double?
        var unit: UnitMass = .pounds
        
        let weightMap: [String: UnitMass] = [
            "lb": .pounds,
            "kg": .kilograms]
        
        for (key, weightUnit) in weightMap {
            if let range = self.range(of: key) {
                value = Double(self[..<range.lowerBound].trimmingCharacters(in: .whitespaces))!
                unit = weightUnit
                break
            }
        }
        // Try converting string to number.
        if value == nil {
            value = Double(self)
        }
        
        // Bail if the value could not be parsed.
        guard value != nil else { return nil }
        
        return Weight(value: value!, unit: unit)
    }
    
}

public extension KeyedDecodingContainer  {
    
    /// Decodes either a number or a string into a Weight.
    ///
    /// - throws `DecodingError.dataCorrupted` if the weight could not be decoded.
    func decode(_ type: Weight.Type, forKey key: K) throws -> Weight {
        let weight: Weight?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            weight = Weight(value: double, unit: .pounds)
        } else {
            weight = try self.decode(String.self, forKey: key).parseWeight
        }
        
        // Throw if we were unsuccessful parsing.
        guard weight != nil else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Missing string or number for Weight value")
            throw DecodingError.dataCorrupted(context)
        }
        
        return weight!
    }
    
    /// Decodes either a number or a string into a Weight, if present.
    ///
    /// - throws `DecodingError.dataCorrupted` if the weight could not be decoded.
    func decodeIfPresent(_ type: Weight.Type, forKey key: K) throws -> Weight? {
        let weight: Weight?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            weight = Weight(value: double, unit: .pounds)
        } else if let string = try self.decodeIfPresent(String.self, forKey: key) {
            weight = string.parseWeight
        } else {
            weight = nil
        }
        
        return weight
    }
    
}

extension Weight {
    
    /// Returns a string representation of the weight suitable for display.
    public var displayString: String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        return formatter.string(from: self)
    }
}
