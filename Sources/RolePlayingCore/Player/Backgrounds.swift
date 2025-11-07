//
//  Backgrounds.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

/// A collection of background traits.
public struct Backgrounds: Codable {
    
    public var backgrounds = [BackgroundTraits]()
    
    private enum CodingKeys: String, CodingKey {
        case backgrounds
    }
    
    public func find(_ backgroundName: String?) -> BackgroundTraits? {
        return backgrounds.first(where: { $0.name == backgroundName })
    }
    
    public var count: Int { return backgrounds.count }
    
    public subscript(index: Int) -> BackgroundTraits? {
        get {
            return backgrounds[index]
        }
    }
    
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> BackgroundTraits {
        return backgrounds.randomElementByIndex(using: &generator)!
    }
}
