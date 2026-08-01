//
//  FeatTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/22/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Traits describing a feat — a special ability a character acquires at character creation
/// or at certain levels. Feats are identified by name; mechanical effects such as ability
/// score increases and proficiencies are available as future extensions.
public struct FeatTraits: Sendable, Equatable {
    public var name: String
    public var description: String
    public var category: Category

    /// The category of a feat, governing when and whether it can be taken.
    public enum Category: String, Codable, CaseIterable, Sendable {
        case origin                        // Background feats; no prerequisites; level 1 only
        case general                       // Most feats; may have prerequisites
        case fightingStyle = "fighting style"
        case epicBoon = "epic boon"        // Level 20 only
    }

    public init(name: String, description: String = "", category: Category = .general) {
        self.name = name
        self.description = description
        self.category = category
    }
}

extension FeatTraits: Codable {
    private enum CodingKeys: String, CodingKey {
        case name, description, category
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try values.decode(String.self, forKey: .name)
        let description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        let category = try values.decodeIfPresent(Category.self, forKey: .category) ?? .general
        self.init(name: name, description: description, category: category)
    }

    public func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(name, forKey: .name)
        if !description.isEmpty {
            try values.encode(description, forKey: .description)
        }
        if category != .general {
            try values.encode(category, forKey: .category)
        }
    }
}
