//
//  CreatureType.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/8/25.
//

public struct CreatureType: Sendable {
    public let name: String
    public let isDefault: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case isDefault = "is default"
    }
    
    init(_ name: String, isDefault: Bool? = nil) {
        self.name = name
        self.isDefault = isDefault
    }
}

extension CreatureType: Codable { }

