//
//  Players.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of player characters.
public class Players: CodableWithConfiguration {
    public var players: [Player]
    
    public init(_ players: [Player] = []) {
        self.players = players
    }
    
    // TODO: inherit protocols for these
    
    public var count: Int { return players.count }
    
    public subscript(index: Int) -> Player? {
        get {
            return players[index]
        }
    }
    
    public func insert(_ player: Player, at index: Int) {
        players.insert(player, at: index)
    }
    
    public func remove(at index: Int) {
        players.remove(at: index)
    }
    
    // MARK: Codable conformance
    
    private enum CodingKeys: String, CodingKey {
        case players
    }
    
    public required init(from decoder: Decoder, configuration: Configuration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        players = try container.decode([Player].self, forKey: .players, configuration: configuration)
    }
    
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players, forKey: .players, configuration: configuration)
    }
}
