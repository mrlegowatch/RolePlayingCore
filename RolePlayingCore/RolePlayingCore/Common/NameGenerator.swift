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
            
            starters.append(seed.substring(to: seed.index(seed.startIndex, offsetBy: starterLength)))
            
            let keyRangeEnd = seedCharacterCount - starterLength + 1
            for keyRangeStart in 0..<keyRangeEnd {
                
                let keyStartIndex = seed.index(seed.startIndex, offsetBy: keyRangeStart)
                let keyEndIndex = seed.index(keyStartIndex, offsetBy: starterLength)
                let keyRange = keyStartIndex..<keyEndIndex
                let key = seed.substring(with: keyRange)
                
                var value = endValue
                let valueRangeStart = keyRangeStart + starterLength
                if valueRangeStart < seedCharacterCount {
                    let valueRange = keyRange.upperBound..<seed.index(after: keyRange.upperBound)
                    value = seed.substring(with: valueRange)
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
    
    /// Set this at startup to use a different random number generator.
    public static var randomNumberGenerator: RandomNumberGenerator = DefaultRandomNumberGenerator()
    
    /// Uses the random number generator to return an integer from 0..<upperBound.
    private func random(_ upperBound: Int) -> Int {
        return NameGenerator.randomNumberGenerator.random(upperBound)
    }
    
    private func randomFirstPart() -> String {
        let whichStarter = random(nameStarters.count)
        return nameStarters[whichStarter]
    }
    
    private func randomPartAfter(_ key: String) -> String {
        let possibleNextParts = nameParts[key]!
        let whichNextPart = random(possibleNextParts.count)
        return possibleNextParts[whichNextPart]
    }
    
    public func makeName() -> String {
        var loopCount = Int.max
        var name = ""
        
        while true {
            if loopCount >= 10 {
                loopCount = 0
                name = randomFirstPart()
            }
            loopCount += 1
            
            let key = name.substring(from: name.index(name.endIndex, offsetBy: -starterLength))
            let nextPart = randomPartAfter(key)
            if nextPart == endValue {
                break
            }
            name += nextPart
        }
        
        return name
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
