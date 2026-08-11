//
//  SpellcastingType.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/9/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// How a class learns and uses spells.
public enum SpellcastingType: String, Codable, CaseIterable, Sendable {
    case prepared
    case known
    case pactMagic = "pact magic"
}
