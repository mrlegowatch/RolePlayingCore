//
//  RandomIndexGeneratorTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore

@Suite("RandomIndexGenerator Tests")
struct RandomIndexGeneratorTests {

    // MARK: - DefaultRandomIndexGenerator

    @Test("DefaultRandomIndexGenerator returns indices within bounds")
    func defaultGeneratorWithinBounds() {
        var gen = DefaultRandomIndexGenerator()
        for _ in 0..<50 {
            let idx = gen.randomIndex(upperBound: 6)
            #expect(idx >= 0 && idx < 6)
        }
    }

    @Test("DefaultRandomIndexGenerator distributes across range")
    func defaultGeneratorDistribution() {
        var gen = DefaultRandomIndexGenerator()
        var seen = Set<Int>()
        for _ in 0..<200 {
            seen.insert(gen.randomIndex(upperBound: 4))
        }
        #expect(seen.count == 4, "Should eventually hit all 4 values")
    }

    // MARK: - MockIndexGenerator

    @Test("MockIndexGenerator returns sequential indices starting at zero")
    func mockGeneratorSequential() {
        var gen = MockIndexGenerator()
        #expect(gen.randomIndex(upperBound: 10) == 0)
        #expect(gen.randomIndex(upperBound: 10) == 1)
        #expect(gen.randomIndex(upperBound: 10) == 2)
        #expect(gen.randomIndex(upperBound: 10) == 3)
    }

    @Test("MockIndexGenerator wraps around upperBound")
    func mockGeneratorWrapsAround() {
        var gen = MockIndexGenerator()
        #expect(gen.randomIndex(upperBound: 3) == 0)
        #expect(gen.randomIndex(upperBound: 3) == 1)
        #expect(gen.randomIndex(upperBound: 3) == 2)
        #expect(gen.randomIndex(upperBound: 3) == 0, "Should wrap to 0")
        #expect(gen.randomIndex(upperBound: 3) == 1, "Should wrap to 1")
    }

    @Test("MockIndexGenerator modulo applied per call with changing bounds")
    func mockGeneratorChangingBounds() {
        var gen = MockIndexGenerator()
        // index 0 % 2 = 0, index 1 % 3 = 1, index 2 % 2 = 0, index 3 % 4 = 3
        #expect(gen.randomIndex(upperBound: 2) == 0)
        #expect(gen.randomIndex(upperBound: 3) == 1)
        #expect(gen.randomIndex(upperBound: 2) == 0)
        #expect(gen.randomIndex(upperBound: 4) == 3)
    }

    // MARK: - Array.randomElementByIndex extensions

    @Test("randomElementByIndex(using:) returns elements in sequential order")
    func randomElementByIndexWithMock() {
        var gen = MockIndexGenerator()
        let array = ["alpha", "beta", "gamma"]
        #expect(array.randomElementByIndex(using: &gen) == "alpha")
        #expect(array.randomElementByIndex(using: &gen) == "beta")
        #expect(array.randomElementByIndex(using: &gen) == "gamma")
        #expect(array.randomElementByIndex(using: &gen) == "alpha", "Wraps back to first")
    }

    @Test("randomElementByIndex() with default generator returns a valid element")
    func randomElementByIndexDefault() {
        let array = [10, 20, 30, 40, 50]
        let result = array.randomElementByIndex()
        #expect(result != nil)
        #expect(array.contains(result!))
    }

    @Test("randomElementByIndex(using:) picks correct element for single-element array")
    func randomElementByIndexSingleElement() {
        var gen = MockIndexGenerator()
        let array = ["only"]
        #expect(array.randomElementByIndex(using: &gen) == "only")
        #expect(array.randomElementByIndex(using: &gen) == "only", "Still picks the one element")
    }
}
