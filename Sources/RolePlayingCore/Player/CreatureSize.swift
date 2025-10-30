//
//  CreatureSize.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/27/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

public enum CreatureSize: String {
    case tiny
    case small
    case medium
    case large
    case huge
    case gargantuan
    
    init(from height: Height) {
        let heightInFeet = height.converted(to: .feet)
        switch heightInFeet.value {
        case 0..<4:
            self = .small
        case 4..<8:
            self = .medium
        default:
            self = .large
        }
    }
    
    // Integer range in inches
    var range: Range<Int> {
        switch self {
        case .tiny: return 12..<24
        case .small: return 24..<48
        case .medium: return 48..<96
        case .large: return 96..<120
        case .huge: return 120..<180
        case .gargantuan: return 180..<240
        }
    }
    
    /// Space required in feet (dimension feet x feet)
    var space: Double {
        switch self {
        case .tiny: return 2.5
        case .small, .medium: return 5.0
        case .large: return 10.0
        case .huge: return 15.0
        case .gargantuan: return 20.0
        }
    }
    
    /// Space required in squares
    var squares: Double {
        switch self {
        case .tiny: return 0.25
        case .small, .medium: return 1.0
        case .large: return 4.0
        case .huge: return 9.0
        case .gargantuan: return 16.0
        }
    }
}

extension Height {
    
    /// Generates a random height from a named size, or a string range "min-max" appended with "ft" (feet) or "in" (inches).
    public static func randomHeight(from rangeString: String) -> Height {
        let range: Range<Int>
        if let namedSize = CreatureSize(rawValue: rangeString) {
            range = namedSize.range
        } else if rangeString.hasSuffix("ft") {
            let minMaxString = rangeString.replacing("ft", with: "").replacing(" ", with: "").components(separatedBy: "-")
            let minValue = (Int(minMaxString[0]) ?? 4) * 12
            let maxValue = (Int(minMaxString[1]) ?? 7) * 12
            range = minValue..<maxValue
        } else if rangeString.hasSuffix("in") {
            let minMaxString = rangeString.replacing("in", with: "").replacing(" ", with: "").components(separatedBy: "-")
            let minValue = Int(minMaxString[0]) ?? 4
            let maxValue = Int(minMaxString[1]) ?? 7
            range = minValue..<maxValue
        } else {
            range = (4 * 12)..<(7 * 12)
        }
       
        return Height(value: Double(range.randomElement()!) / 12.0, unit: .feet)
    }
}
