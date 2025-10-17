//
//  Races.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public class Races: Codable {
    
    /// Accesses all of the races and subraces that have been loaded.
    public var races = [RacialTraits]()
    
    /// Creates a Races instance.
    public init() { }
    
    /// Returns all of the leaf races (races that contain no subraces).
    public var leafRaces: [RacialTraits] {
        return races.filter { (racialTraits) -> Bool in
            racialTraits.subraces.count == 0
        }
    }
    
    /// Returns the race matching the specified name, or nil if not present.
    public func find(_ raceName: String?) -> RacialTraits? {
        guard raceName != nil else { return nil }
        
        return races.first(where: { $0.name == raceName })
    }

    public var count: Int { return races.count }
    
    public subscript(index: Int) -> RacialTraits? {
        get {
            return races[index]
        }
    }
    
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> RacialTraits {
        return races.randomElementByIndex(using: &generator)!
    }
    
    enum CodingKeys: String, CodingKey {
        case races
    }
    
    /// Overridden to stitch together subraces embedded in races.
    public required init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        var leaf = try root.nestedUnkeyedContainer(forKey: .races)
        
        var races = [RacialTraits]()
        while (!leaf.isAtEnd) {
            let racialTraits = try leaf.decode(RacialTraits.self)
            races.append(racialTraits)
            
            /// If there are subraces, append those
            for subrace in racialTraits.subraces {
                races.append(subrace)
            }
        }
        
        self.races = races
    }
    
}
