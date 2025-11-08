//
//  Backgrounds.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of backgrounds.
public struct Backgrounds: CodableWithConfiguration {
    
    public var backgrounds: [BackgroundTraits]
    
    public init(_ backgrounds: [BackgroundTraits] = []) {
        self.backgrounds = backgrounds
    }
    
    public func find(_ backgroundName: String?) -> BackgroundTraits? {
        return backgrounds.first(where: { $0.name == backgroundName })
    }
    
    public var count: Int { return backgrounds.count }
    
    public subscript(index: Int) -> BackgroundTraits? {
        get {
            guard index >= 0 && index < backgrounds.count else { return nil }
            return backgrounds[index]
        }
    }
    
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> BackgroundTraits {
        return backgrounds.randomElementByIndex(using: &generator)!
    }

    // MARK: Codable conformance
    
    private enum CodingKeys: String, CodingKey {
        case backgrounds
    }
    
    public init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.backgrounds = try values.decode([BackgroundTraits].self, forKey: .backgrounds, configuration: configuration)
    }
    
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backgrounds, forKey: .backgrounds, configuration: configuration)
    }
}
