//
//  DescriptiveTraitKey.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Well-known string keys for descriptive trait dictionaries on `Player`, `BackgroundTraits`,
/// `SpeciesTraits`, and `ClassTraits`.
///
/// The backing store is always `[String: String]`, so any additional key can be stored
/// freely — these constants supply a shared vocabulary and enable builder UIs to
/// enumerate known fields via `CaseIterable`.
public enum DescriptiveTraitKey: String, CaseIterable, Sendable {

    // MARK: Physical appearance

    case hairColor = "hair color"
    case eyeColor  = "eye color"
    case skinColor = "skin color"

    // MARK: Personal

    case age       = "age"
    case birthdate = "birthdate"

    // MARK: Personality flavor (typically seeded from background)

    case personalityTrait = "personality trait"
    case ideal     = "ideal"
    case bond      = "bond"
    case flaw      = "flaw"
    case backstory = "backstory"
}
