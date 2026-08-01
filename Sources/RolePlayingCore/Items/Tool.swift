//
//  Tool.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
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
        case name, plural, cost, weight
        case toolType = "tool type"
    }

    public init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name     = try values.decode(String.self, forKey: .name)
        plural   = try values.decodeIfPresent(String.self, forKey: .plural) ?? (name + "s")
        cost     = (try? values.decode(Money.self, forKey: .cost, configuration: configuration.currencies)) ?? .zero
        weight   = (try? values.decode(Weight.self, forKey: .weight)) ?? Weight(value: 0, unit: .pounds)
        toolType = try values.decode(ToolType.self, forKey: .toolType)
    }

    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(name, forKey: .name)
        if plural != name + "s" {
            try values.encode(plural, forKey: .plural)
        }
        try values.encode(cost, forKey: .cost, configuration: configuration.currencies)
        try values.encode(weight.value, forKey: .weight)
        try values.encode(toolType, forKey: .toolType)
    }
}
