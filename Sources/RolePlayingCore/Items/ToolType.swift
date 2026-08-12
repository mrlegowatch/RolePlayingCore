//
//  ToolType.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// The functional type of a tool, used when resolving tool proficiency.
///
/// Modeled as a string-backed struct for extensibility across game systems.
public struct ToolType: Sendable, Hashable, Codable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

extension ToolType: CustomStringConvertible {
    public var description: String { name }
}

// MARK: - Default Tool Types

extension ToolType {
    public static let artisans = ToolType("artisan's tools")
    public static let musical = ToolType("musical instrument")
    public static let gaming = ToolType("gaming set")
    public static let thieves = ToolType("thieves' tools")
    public static let navigator = ToolType("navigator's tools")
    public static let herbalism = ToolType("herbalism kit")
    public static let poisoner = ToolType("poisoner's kit")
    public static let forgery = ToolType("forgery kit")
    public static let disguise = ToolType("disguise kit")
    public static let cartographer = ToolType("cartographer's tools")
}
