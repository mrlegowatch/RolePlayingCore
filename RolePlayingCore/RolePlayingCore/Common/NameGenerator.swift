//
//  NameGenerator.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/26/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//
//  Based on MarkovNameChain.m by Mike Carney,
//  Copyright © 2009 Sweet-Spot Software, MIT License.

/// This implements a Markov-Chain-based name generator.
/// See <http://en.wikipedia.org/wiki/Markov_chains> for a description.
public struct NameGenerator {
    
    private var nameStarters: [String]
    private var nameParts: [String: [String]]
    
    private let starterLength = 2
    private let endValue = "$"
    
    /// Creates a name generator using an array of seed names.
    public init(_ seeds: [String]) {
        // Convert the seeds into name starters and name parts
        var starters = [String]()
        var parts = [String: [String]]()
        
        for seed in seeds {
            let seedCharacterCount = seed.count
            guard seedCharacterCount > starterLength else { continue }
            
            starters.append(String(seed[..<seed.index(seed.startIndex, offsetBy: starterLength)]))
            
            let keyRangeEnd = seedCharacterCount - starterLength + 1
            for keyRangeStart in 0..<keyRangeEnd {
                
                let keyStartIndex = seed.index(seed.startIndex, offsetBy: keyRangeStart)
                let keyEndIndex = seed.index(keyStartIndex, offsetBy: starterLength)
                let keyRange = keyStartIndex..<keyEndIndex
                let key = String(seed[keyRange])
                
                var value = endValue
                let valueRangeStart = keyRangeStart + starterLength
                if valueRangeStart < seedCharacterCount {
                    let valueRange = keyRange.upperBound..<seed.index(after: keyRange.upperBound)
                    value = String(seed[valueRange])
                }
                
                if parts[key] == nil {
                    parts[key] = [String]()
                }
                parts[key]!.append(value)
            }
        }
        
        self.nameStarters = starters
        self.nameParts = parts
    }

    private func randomFirstPart<G: RandomIndexGenerator>(using generator: inout G) -> String {
        let randomIndex = generator.randomIndex(upperBound: nameStarters.count)
        return nameStarters[randomIndex]
    }
    
    private func randomPartAfter<G: RandomIndexGenerator>(_ key: String, using generator: inout G) -> String {
        let possibleNextParts = nameParts[key]!
        let randomIndex = generator.randomIndex(upperBound: possibleNextParts.count)
        return possibleNextParts[randomIndex]
    }
    
    /// Returns a generated name.
    public func makeName<G: RandomIndexGenerator>(using generator: inout G) -> String {
        var loopCount = Int.max
        var name = ""
        
        while true {
            if loopCount >= 10 {
                loopCount = 0
                name = randomFirstPart(using: &generator)
            }
            loopCount += 1
            
            let key = String(name[name.index(name.endIndex, offsetBy: -starterLength)...])
            let nextPart = randomPartAfter(key, using: &generator)
            if nextPart == endValue {
                break
            }
            name += nextPart
        }
        
        return name
    }
    
    /// Returns a generated name.
    public func makeName() -> String {
        var rng = DefaultRandomIndexGenerator()
        return makeName(using: &rng)
    }
}

extension NameGenerator: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case names
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let names = try container.decode([String].self, forKey: .names)
        self.init(names)
    }
}
