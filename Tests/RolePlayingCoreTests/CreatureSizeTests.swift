//
//  CreatureSizeTests.swift
//  RolePlayingCore
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

@Suite("CreatureSize Tests")
struct CreatureSizeTests {

    // MARK: - RawValue / init(rawValue:)

    @Test("All cases have correct raw values")
    func rawValues() {
        #expect(CreatureSize.tiny.rawValue == "tiny")
        #expect(CreatureSize.small.rawValue == "small")
        #expect(CreatureSize.medium.rawValue == "medium")
        #expect(CreatureSize.large.rawValue == "large")
        #expect(CreatureSize.huge.rawValue == "huge")
        #expect(CreatureSize.gargantuan.rawValue == "gargantuan")
    }

    @Test("Init from raw value")
    func initFromRawValue() {
        #expect(CreatureSize(rawValue: "medium") == .medium)
        #expect(CreatureSize(rawValue: "large") == .large)
        #expect(CreatureSize(rawValue: "unknown") == nil)
    }

    // MARK: - Init from height (internal)

    @Test("Init from height: small for heights under 4 ft")
    func initFromHeightSmall() {
        let height = Height(value: 3.5, unit: .feet)
        #expect(CreatureSize(from: height) == .small)

        let heightInCm = Height(value: 90, unit: .centimeters) // ~2.95 ft
        #expect(CreatureSize(from: heightInCm) == .small)
    }

    @Test("Init from height: medium for 4–8 ft")
    func initFromHeightMedium() {
        #expect(CreatureSize(from: Height(value: 4.0, unit: .feet)) == .medium)
        #expect(CreatureSize(from: Height(value: 5.5, unit: .feet)) == .medium)
        #expect(CreatureSize(from: Height(value: 7.9, unit: .feet)) == .medium)
    }

    @Test("Init from height: large for 8 ft and over")
    func initFromHeightLarge() {
        #expect(CreatureSize(from: Height(value: 8.0, unit: .feet)) == .large)
        #expect(CreatureSize(from: Height(value: 10.0, unit: .feet)) == .large)
    }

    // MARK: - Range (internal)

    @Test("Range values cover expected inch spans")
    func rangeValues() {
        #expect(CreatureSize.tiny.range == 12..<24)
        #expect(CreatureSize.small.range == 24..<48)
        #expect(CreatureSize.medium.range == 48..<96)
        #expect(CreatureSize.large.range == 96..<120)
        #expect(CreatureSize.huge.range == 120..<180)
        #expect(CreatureSize.gargantuan.range == 180..<240)
    }

    @Test("Ranges are contiguous from tiny to gargantuan")
    func rangesAreContiguous() {
        let cases: [CreatureSize] = [.tiny, .small, .medium, .large, .huge, .gargantuan]
        for i in 0..<(cases.count - 1) {
            #expect(cases[i].range.upperBound == cases[i + 1].range.lowerBound,
                    "\(cases[i]) upper bound should equal \(cases[i + 1]) lower bound")
        }
    }

    // MARK: - Space (internal)

    @Test("Space in feet for all sizes")
    func spaceInFeet() {
        #expect(CreatureSize.tiny.space == 2.5)
        #expect(CreatureSize.small.space == 5.0)
        #expect(CreatureSize.medium.space == 5.0)
        #expect(CreatureSize.large.space == 10.0)
        #expect(CreatureSize.huge.space == 15.0)
        #expect(CreatureSize.gargantuan.space == 20.0)
    }

    // MARK: - Squares (internal)

    @Test("Space in squares for all sizes")
    func squaresOccupied() {
        #expect(CreatureSize.tiny.squares == 0.25)
        #expect(CreatureSize.small.squares == 1.0)
        #expect(CreatureSize.medium.squares == 1.0)
        #expect(CreatureSize.large.squares == 4.0)
        #expect(CreatureSize.huge.squares == 9.0)
        #expect(CreatureSize.gargantuan.squares == 16.0)
    }

    // MARK: - Height.randomHeight(from:)

    @Test("Random height from named size stays within size range")
    func randomHeightFromNamedSize() {
        for _ in 0..<20 {
            let height = Height.randomHeight(from: "medium")
            let inches = height.converted(to: .feet).value * 12
            #expect(inches >= 48 && inches < 96, "Medium height should be 48–95 in, got \(inches)")
        }
    }

    @Test("Random height from feet range string")
    func randomHeightFromFeetRange() {
        for _ in 0..<20 {
            let height = Height.randomHeight(from: "5-7ft")
            let feet = height.converted(to: .feet).value
            #expect(feet >= 5.0 && feet < 7.0, "Height should be 5–6.x ft, got \(feet)")
        }
    }

    @Test("Random height from inches range string")
    func randomHeightFromInchesRange() {
        for _ in 0..<20 {
            let height = Height.randomHeight(from: "60-72in")
            let inches = height.converted(to: .feet).value * 12
            #expect(inches >= 60 && inches < 72, "Height should be 60–71 in, got \(inches)")
        }
    }

    @Test("Random height falls back to 4–7 ft for unrecognized string")
    func randomHeightFallback() {
        for _ in 0..<20 {
            let height = Height.randomHeight(from: "unknown_size")
            let feet = height.converted(to: .feet).value
            #expect(feet >= 4.0 && feet < 7.0, "Fallback height should be 4–6.x ft, got \(feet)")
        }
    }
}
