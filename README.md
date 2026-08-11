# RolePlayingCore  [![Build Status](https://github.com/mrlegowatch/RolePlayingCore/workflows/Build/badge.svg)](https://github.com/mrlegowatch/RolePlayingCore/workflows/swift.yml)
![Code Coverage](https://codecov.io/gh/mrlegowatch/RolePlayingCore/branch/development/graph/badge.svg)
![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Swift package providing reusable core logic for role-playing games. It is a work in progress — capabilities are added incrementally.

The short-term goal is to cover the key moving parts of a tabletop RPG character: species, class, background, ability scores, skills, spells, equipment, and the random-generation plumbing that ties them together. The architecture is designed to be flexible enough to support Open Game Content and similar game systems, and to minimize upstream dependencies.

The library is a generic Swift Package. The included CharacterGenerator example app demonstrates iOS/macOS usage with a full SwiftUI character-builder workflow.

## Dependencies

RolePlayingCore depends on [SwiftDice](https://github.com/mrlegowatch/SwiftDice), which provides the `Rollable` protocol, dice types (`Dice`, `CompoundDice`, …), and a dice-notation parser.

## Organization

The source code is grouped into the following modules under `Sources/RolePlayingCore`:

| Group | What's inside |
|---|---|
| **Common** | `Height`, `Weight`, `CharacterNames`, `Named` & `DisplayOrdered` protocols |
| **Configuration** | `GameData`, `GameDataFiles`, `GameDataError`, `Bundle+JSONFile` |
| **Currency** | `UnitCurrency`, `Money`, `Currencies` |
| **Items** | `Item`, `Weapon`, `Armor`, `Gear`, `Tool`, `EquipmentOptions`, `InventoryEntry`, damage types, weapon properties |
| **Player** | `Player`, `Players`, `Ability`, `Alignment`, `ClassTraits`/`Classes`, `SpeciesTraits`/`Species`, `BackgroundTraits`/`Backgrounds`, `Skill`/`Skills`, `FeatTraits`/`Feats`, `Spell`/`Spells`, `SubclassTraits`, `UnarmoredDefense`, `CreatureType`, `Initiative` |
| **CharacterGenerator** | `CharacterGenerator`, `NameGenerator` |

## Example App

`Examples/CharacterGenerator` is a SwiftUI iOS/macOS app that demonstrates the full library. It loads all game data from JSON at launch via `GameData` and provides:

- A **character builder** — a step-by-step navigation flow for choosing species, class, background, ability scores, skills, and spells, finishing with a name
- A **player list** with a detail sheet showing abilities, skills, inventory, and spells
- Random character generation using `CharacterGenerator`

## Game Data

All game content is stored in JSON files and decoded at launch by `GameData`. The configuration entry point is a manifest JSON (e.g. `Configuration.json`) that lists the file names to load for each content type:

```json
{
    "currencies": ["Currencies"],
    "skills":  ["Skills"],
    "feats":   ["Feats"],
    "spells":  ["Spells"],
    "items":   ["Items"],
    "backgrounds": ["Backgrounds"],
    "creature types": ["CreatureTypes"],
    "species": ["Species"],
    "classes": ["Classes"]
}
```

Collection types (`Backgrounds`, `Classes`, `Species`) decode via Apple's `CodableWithConfiguration` protocol, which threads the partially-loaded `GameData` context through the decoder so nested types (equipment, skills, spells) can resolve cross-references during decoding.

### Display Ordering

Collections support an optional `"display order"` key in their JSON. When present, `allByDisplayOrder` returns elements in that order (with alphabetical fallback for unlisted names). This is exposed through the `DisplayOrdered` protocol, which `Backgrounds`, `Classes`, and `Species` all conform to.

### Default Backgrounds

Each class entry in `Classes.json` can carry an optional `"default background"` key. The character builder uses this to pre-select the most thematically appropriate background when a class is chosen.

## What Is Implemented

### Common

- **`Named`** — protocol requiring `var name: String`. Adopted by `BackgroundTraits`, `ClassTraits`, and `SpeciesTraits`.
- **`DisplayOrdered`** — protocol for collections that have a `displayOrder: [String]` and an `all: [Element]` array. Provides a default `allByDisplayOrder` computed property that sorts by the display order array and falls back alphabetically.
- **`Height`** / **`Weight`** — typealiases and string-parsing helpers built on `Foundation.Measurement`.
- **`CharacterNames`** — loads first and last name lists from JSON for use by `NameGenerator`.

### Configuration

- **`GameData`** — the top-level loader. Initialized with a bundle and a manifest filename; loads all content types in dependency order. Content is accessed via properties such as `gameData.classes`, `gameData.backgrounds`, `gameData.spells`.
- **`GameDataFiles`** — `Decodable` manifest struct describing which JSON files to load for each content type.
- **`GameDataError`** — typed errors thrown during loading (missing file, decode failure, etc.).

### Currency

- **`UnitCurrency`** — a `Foundation.Dimension` subclass that converts between denominations (cp, sp, ep, gp, pp).
- **`Money`** — a `Foundation.Measurement<UnitCurrency>` with formatting and arithmetic.
- **`Currencies`** — collection loaded from JSON; provides lookup by abbreviation.

### Items

- **`Item`** — base item with name, weight, value, and quantity.
- **`Weapon`** — adds damage roll, properties (finesse, thrown, …), range, and proficiency category.
- **`Armor`** — adds AC formula, weight category, and dexterity modifier rule.
- **`Gear`** / **`Tool`** — general equipment variants.
- **`EquipmentOptions`** — a list of item-choice alternatives (e.g. "Option A or Option B"), decoded from nested JSON arrays. Used for class and background starting equipment.
- **`InventoryEntry`** — pairs an `Item` with a quantity and equipped flag; used by `Player`.
- **`WeaponProficiency`** — represents a proficiency by category (simple, martial) or specific weapon name.

### Player

- **`Player`** — the main character class. Holds species, class, background, ability scores, skill proficiencies, inventory, and prepared spells. Can compute AC, HP, initiative, ability modifiers, and proficiency bonus.
- **`Players`** — a `CodableWithConfiguration` collection of `Player` instances.
- **`Ability`** — named ability (Strength, Dexterity, …) with a `scoreModifier` extension on `Int` that computes the standard floor-divided modifier.
- **`AbilityScores`** — a keyed container for the six base scores with roll-4d6-drop-lowest support.
- **`CharacterAlignment`** — ethics × morals enumeration with associated display names.
- **`ClassTraits`** — describes a class: hit dice, primary ability, saving throws, skill and weapon proficiencies, armor training, starting equipment, spellcasting ability and type, spell slots, cantrips/spells known, subclass details, and an optional suggested `defaultBackground`.
- **`Classes`** — `CodableWithConfiguration`, `DisplayOrdered` collection of `ClassTraits`. Supports an optional shared experience-points table and a `"display order"` array.
- **`SubclassTraits`** — describes a subclass with its own descriptive traits.
- **`SpeciesTraits`** — describes a species: lifespan, size, speed, darkvision, creature type, traits, and optional subspecies. The `parentName` property links subspecies to their parent.
- **`Species`** — `CodableWithConfiguration`, `DisplayOrdered` collection. Custom decoder stitches subspecies into the flat `allSpecies` dictionary; encoder writes only root species (with embedded subspecies).
- **`BackgroundTraits`** — describes a background: ability scores, feat, skill proficiencies, tool proficiency, and equipment options.
- **`Backgrounds`** — `CodableWithConfiguration`, `DisplayOrdered` collection of `BackgroundTraits`. Supports a `"display order"` array.
- **`Skill`** / **`Skills`** — named skill with associated ability.
- **`FeatTraits`** / **`Feats`** — feat with name and optional prerequisites.
- **`Spell`** / **`Spells`** — spell with school, level, casting time, range, components, duration, and class lists.
- **`UnarmoredDefense`** — computes AC from a list of ability modifiers (e.g. Barbarian's CON bonus).
- **`CreatureType`** / **`CreatureTypes`** — creature type taxonomy (humanoid, beast, …).
- **`Initiative`** — computed initiative value with optional tiebreaker.

### CharacterGenerator

- **`CharacterGenerator`** — generates randomised `Player` instances by sampling from the loaded `GameData`. Uses `SwiftDice` for all die rolls.
- **`NameGenerator`** — produces random names by combining first and last names loaded from `CharacterNames.json`.

## Coming Soon

Currently in development as a Swift package that depends on RolePlayingCore:
- **Dungeon**: Document wrapper for `Map` instances
- **DungeonMap**: `Map`, `Room`, `Door`, `Hallway`, geometry primitives
---

To learn about the origin of the dice types that power random generation, see the three-part series on Medium:
* [So, I made a Dice class](https://medium.com/@mrlegowatch/so-i-made-a-dice-class-1-of-3-9b9bb5c1dc2)
* [So, I tested Dice and added a parser](https://medium.com/@mrlegowatch/so-i-tested-dice-and-added-a-parser-2-of-3-80335e08ddf8)
* [So, Dice is in GitHub now](https://medium.com/@mrlegowatch/so-dice-is-in-github-now-3-3-204fd6c40fc0)

For background on why `Codable` was applied across this repository:
* [OMG, Codable is so frickin' awesome](https://medium.com/@mrlegowatch/omg-codable-is-so-frickin-awesome-bb9ff33139da)
