//
//  ArmorTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Armor Tests", .serialized)
struct ArmorTests {

    let gameData: GameData

    init() throws {
        gameData = try GameData("TestArmorConfiguration", from: .module)
    }

    // MARK: - DexterityModifierRule

    @Test("DexterityModifierRule parses all variants")
    func dexterityModifierRuleParsing() {
        #expect(DexterityModifierRule(parsing: "full")     == .full)
        #expect(DexterityModifierRule(parsing: "excluded") == .excluded)
        #expect(DexterityModifierRule(parsing: "bonus")    == .bonus)
        #expect(DexterityModifierRule(parsing: "capped 2") == .capped(2))
        #expect(DexterityModifierRule(parsing: "capped 3") == .capped(3))
        #expect(DexterityModifierRule(parsing: "unknown")  == nil)
    }

    @Test("DexterityModifierRule round-trips through description")
    func dexterityModifierRuleDescription() {
        #expect(DexterityModifierRule.full.description        == "full")
        #expect(DexterityModifierRule.excluded.description    == "excluded")
        #expect(DexterityModifierRule.bonus.description       == "bonus")
        #expect(DexterityModifierRule.capped(2).description   == "capped 2")
    }

    // MARK: - ArmorClass computation via Player

    private func makePlayer(baseAbilities: [String: Int] = [:],
                            unarmoredDefense: UnarmoredDefense? = nil) -> Player {
        var classTraits = gameData.classes["Fighter"]!
        if let ud = unarmoredDefense {
            classTraits.unarmoredDefense = ud
        }

        let backgroundTraits = gameData.backgrounds["Sailor"]!
        let speciesTraits = gameData.species["Human"]!

        let player = Player(
            "Test",
            backgroundTraits: backgroundTraits,
            speciesTraits: speciesTraits,
            classTraits: classTraits
        )

        for (name, value) in baseAbilities {
            player.baseAbilities[Ability(name)] = value
        }

        return player
    }

    @Test("Unarmored AC is 10 + DEX modifier")
    func unarmoredAC() {
        // DEX 14 → modifier +2 → AC 12
        let player = makePlayer(baseAbilities: ["Dexterity": 14])
        #expect(player.equippedArmor == nil)
        #expect(player.armorClass == 12)
    }

    @Test("Light armor: base AC + full DEX modifier")
    func lightArmorAC() {
        let player = makePlayer(baseAbilities: ["Dexterity": 16])  // DEX mod +3
        let leather = gameData.items["Leather Armor"] as! Armor  // base 11
        player.inventory.append(InventoryEntry(item: leather, isEquipped: true))
        #expect(player.armorClass == 14)  // 11 + 3
    }

    @Test("Medium armor: base AC + DEX capped at +2")
    func mediumArmorAC() {
        let player = makePlayer(baseAbilities: ["Dexterity": 18])  // DEX mod +4, capped at +2
        let chainShirt = gameData.items["Chain Shirt"] as! Armor  // base 13, capped 2
        player.inventory.append(InventoryEntry(item: chainShirt, isEquipped: true))
        #expect(player.armorClass == 15)  // 13 + 2
    }

    @Test("Heavy armor: fixed base AC, no DEX modifier")
    func heavyArmorAC() {
        let player = makePlayer(baseAbilities: ["Dexterity": 18])  // DEX mod +4, ignored
        let chainMail = gameData.items["Chain Mail"] as! Armor  // base 16, excluded
        player.inventory.append(InventoryEntry(item: chainMail, isEquipped: true))
        #expect(player.armorClass == 16)
    }

    @Test("Shield adds flat bonus to unarmored AC")
    func shieldBonus() {
        let player = makePlayer(baseAbilities: ["Dexterity": 14])  // unarmored AC 12
        let shield = gameData.items["Shield"] as! Armor        // +2 bonus
        player.inventory.append(InventoryEntry(item: shield, isEquipped: true))
        #expect(player.armorClass == 14)  // 12 + 2
    }

    @Test("Light armor + shield stack correctly")
    func armorAndShield() {
        let player = makePlayer(baseAbilities: ["Dexterity": 14])  // DEX mod +2
        let leather = gameData.items["Leather Armor"] as! Armor  // base 11 + dex = 13
        let shield  = gameData.items["Shield"] as! Armor          // +2
        player.inventory.append(InventoryEntry(item: leather, isEquipped: true))
        player.inventory.append(InventoryEntry(item: shield, isEquipped: true))
        #expect(player.armorClass == 15)  // 11 + 2 + 2
    }

    @Test("Unarmored Defense: Barbarian adds CON modifier")
    func unarmoredDefenseBarbarian() {
        // DEX 12 (+1), CON 16 (+3) → AC = 10 + 1 + 3 = 14
        let barbUD = UnarmoredDefense(additionalAbilities: [.constitution])
        let player = makePlayer(
            baseAbilities: ["Dexterity": 12, "Constitution": 16],
            unarmoredDefense: barbUD
        )
        #expect(player.equippedArmor == nil)
        #expect(player.armorClass == 14)
    }

    @Test("Unarmored Defense: Monk adds WIS modifier")
    func unarmoredDefenseMonk() {
        // DEX 14 (+2), WIS 16 (+3) → AC = 10 + 2 + 3 = 15
        let monkUD = UnarmoredDefense(additionalAbilities: [.wisdom])
        let player = makePlayer(
            baseAbilities: ["Dexterity": 14, "Wisdom": 16],
            unarmoredDefense: monkUD
        )
        #expect(player.armorClass == 15)
    }

    // MARK: - ArmorProficiency

    @Test("ArmorProficiency decodes from raw values")
    func armorProficiencyDecode() throws {
        let json = #"["light", "medium", "heavy", "shield"]"#
        let profs = try JSONDecoder().decode([ArmorProficiency].self, from: Data(json.utf8))
        #expect(profs == [.light, .medium, .heavy, .shield])
    }

    @Test("Classes have correct armor training")
    func classArmorTraining() {
        let cleric  = gameData.classes["Cleric"]!
        let fighter = gameData.classes["Fighter"]!
        let wizard  = gameData.classes["Wizard"]!

        #expect(cleric.armorTraining.contains(.medium))
        #expect(cleric.armorTraining.contains(.shield))
        #expect(!cleric.armorTraining.contains(.heavy))

        #expect(fighter.armorTraining.contains(.heavy))
        #expect(fighter.armorTraining.contains(.shield))

        #expect(wizard.armorTraining.isEmpty)
    }

    // MARK: - UnarmoredDefense codable

    @Test("UnarmoredDefense encodes and decodes")
    func unarmoredDefenseRoundTrip() throws {
        let ud = UnarmoredDefense(additionalAbilities: [.constitution])
        let data = try JSONEncoder().encode(ud)
        let decoded = try JSONDecoder().decode(UnarmoredDefense.self, from: data)
        #expect(decoded.additionalAbilities.map(\.name) == ["Constitution"])
    }

    // MARK: - Armor programmatic init

    @Test("Armor programmatic init stores all properties")
    func initAllProperties() {
        let zeroCost = Money(value: 0, unit: UnitCurrency.baseUnit())
        let armor = Armor(
            name: "Plate",
            cost: zeroCost,
            weight: Weight(value: 65, unit: .pounds),
            category: .heavy,
            baseAC: 18,
            dexterityModifierRule: .excluded,
            strengthRequirement: 15,
            stealthDisadvantage: true
        )
        #expect(armor.name == "Plate")
        #expect(armor.plural == "Plates")
        #expect(armor.category == .heavy)
        #expect(armor.baseAC == 18)
        #expect(armor.dexterityModifierRule == .excluded)
        #expect(armor.strengthRequirement == 15)
        #expect(armor.stealthDisadvantage == true)
    }

    @Test("Armor init defaults plural to name + 's' and stealthDisadvantage to false")
    func initDefaults() {
        let zeroCost = Money(value: 0, unit: UnitCurrency.baseUnit())
        let armor = Armor(
            name: "Buckler",
            cost: zeroCost,
            weight: Weight(value: 3, unit: .pounds),
            category: .shield,
            baseAC: 1,
            dexterityModifierRule: .bonus
        )
        #expect(armor.plural == "Bucklers")
        #expect(armor.strengthRequirement == nil)
        #expect(armor.stealthDisadvantage == false)
    }

    // MARK: - Armor decode with missing optional fields

    @Test("Decode armor with missing plural defaults to name + 's'")
    func decodeMissingPlural() throws {
        let json = """
        {"name": "Buckler", "category": "shield", "base ac": 1, "dexterity modifier": "bonus"}
        """.data(using: .utf8)!
        let armor = try JSONDecoder().decode(Armor.self, from: json, configuration: gameData)
        #expect(armor.plural == "Bucklers")
    }

    @Test("Decode armor with missing weight defaults to zero pounds")
    func decodeMissingWeight() throws {
        let json = """
        {"name": "Buckler", "category": "shield", "base ac": 1, "dexterity modifier": "bonus"}
        """.data(using: .utf8)!
        let armor = try JSONDecoder().decode(Armor.self, from: json, configuration: gameData)
        #expect(armor.weight.value == 0)
        #expect(armor.weight.unit == .pounds)
    }

    @Test("Decode armor with missing strengthRequirement and stealthDisadvantage defaults")
    func decodeMissingOptionalFields() throws {
        let json = """
        {"name": "Buckler", "category": "shield", "base ac": 1, "dexterity modifier": "bonus"}
        """.data(using: .utf8)!
        let armor = try JSONDecoder().decode(Armor.self, from: json, configuration: gameData)
        #expect(armor.strengthRequirement == nil)
        #expect(armor.stealthDisadvantage == false)
    }

    // MARK: - Armor encode round-trip

    @Test("Armor encode round-trip preserves all properties")
    func armorEncodeRoundTrip() throws {
        let original = gameData.items["Chain Mail"] as! Armor
        let data = try JSONEncoder().encode(original, configuration: gameData)
        let decoded = try JSONDecoder().decode(Armor.self, from: data, configuration: gameData)
        #expect(decoded.name == original.name)
        #expect(decoded.category == original.category)
        #expect(decoded.baseAC == original.baseAC)
        #expect(decoded.dexterityModifierRule == original.dexterityModifierRule)
        #expect(decoded.strengthRequirement == original.strengthRequirement)
        #expect(decoded.stealthDisadvantage == original.stealthDisadvantage)
    }
}
