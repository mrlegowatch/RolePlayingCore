//
//  Tool.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import Foundation

/// A tool that grants an ability check bonus when the character is proficient with it.
public struct Tool: Item {
    public var name: String
    public var plural: String
    public var cost: Money
    public var weight: Weight
    public var toolType: ToolType

    public init(
        name: String,
        plural: String? = nil,
        cost: Money,
        weight: Weight,
        toolType: ToolType
    ) {
        self.name = name
        self.plural = plural ?? name + "s"
        self.cost = cost
        self.weight = weight
        self.toolType = toolType
    }
}

extension Tool: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case cost
        case weight
        case toolType = "tool type"
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        plural = try container.decodeIfPresent(String.self, forKey: .plural) ?? (name + "s")
        cost = (try? container.decode(Money.self, forKey: .cost, configuration: configuration.currencies)) ?? Money()
        weight = (try? container.decode(Weight.self, forKey: .weight)) ?? Weight(value: 0, unit: .pounds)
        toolType = try container.decode(ToolType.self, forKey: .toolType)
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if plural != name + "s" {
            try container.encode(plural, forKey: .plural)
        }
        try container.encode(cost, forKey: .cost, configuration: configuration.currencies)
        try container.encode(weight.value, forKey: .weight)
        try container.encode(toolType, forKey: .toolType)
    }
}
