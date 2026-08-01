//
//  SkillsTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

@Suite("Skills Tests")
struct SkillsTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    // MARK: - Skill

    @Test("Skill stores name and ability")
    func skillInit() {
        let skill = Skill(name: "Acrobatics", ability: .dexterity)
        #expect(skill.name == "Acrobatics")
        #expect(skill.ability == .dexterity)
    }

    @Test("Skill Codable round-trip via JSON")
    func skillCodableRoundTrip() throws {
        let original = Skill(name: "Stealth", ability: .dexterity)
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Skill.self, from: data)
        #expect(decoded.name == "Stealth")
        #expect(decoded.ability == .dexterity)
    }

    @Test("Skill Hashable: equal skills hash the same, different skills differ")
    func skillHashable() {
        let a = Skill(name: "Perception", ability: .wisdom)
        let b = Skill(name: "Perception", ability: .wisdom)
        let c = Skill(name: "Insight", ability: .wisdom)
        #expect(a == b)
        #expect(a != c)
        let set = Set([a, b, c])
        #expect(set.count == 2)
    }

    // MARK: - Skills collection

    @Test("Skills init creates empty collection")
    func skillsEmptyInit() {
        let skills = Skills()
        #expect(skills.count == 0)
        #expect(skills.all.isEmpty)
        #expect(skills["Acrobatics"] == nil)
    }

    @Test("Skills init with array stores skills accessible by name")
    func skillsInitWithArray() {
        let acrobatics = Skill(name: "Acrobatics", ability: .dexterity)
        let perception = Skill(name: "Perception", ability: .wisdom)
        let skills = Skills([acrobatics, perception])
        #expect(skills.count == 2)
        #expect(skills["Acrobatics"]?.name == "Acrobatics")
        #expect(skills["Perception"]?.name == "Perception")
        #expect(skills["Unknown"] == nil)
    }

    @Test("Skills subscript by index returns skill")
    func skillsSubscriptByIndex() {
        let acrobatics = Skill(name: "Acrobatics", ability: .dexterity)
        let skills = Skills([acrobatics])
        #expect(skills[0]?.name == "Acrobatics")
    }

    @Test("Skills deduplicates by name on init (last wins)")
    func skillsDeduplicates() {
        let v1 = Skill(name: "Athletics", ability: .strength)
        let v2 = Skill(name: "Athletics", ability: .dexterity)
        let skills = Skills([v1, v2])
        #expect(skills.count == 1)
        #expect(skills["Athletics"]?.ability == .dexterity)
    }

    // MARK: - Skills Codable

    @Test("Skills decodes from JSON with 'skills' key")
    func skillsDecode() throws {
        let json = """
        {
            "skills": [
                {"name": "Acrobatics", "ability": "Dexterity"},
                {"name": "Perception", "ability": "Wisdom"}
            ]
        }
        """.data(using: .utf8)!
        let skills = try decoder.decode(Skills.self, from: json)
        #expect(skills.count == 2)
        #expect(skills["Acrobatics"] != nil)
        #expect(skills["Perception"] != nil)
    }

    @Test("Skills encodes with 'skills' key and round-trips")
    func skillsRoundTrip() throws {
        let json = """
        {
            "skills": [
                {"name": "Stealth", "ability": "Dexterity"},
                {"name": "History", "ability": "Intelligence"}
            ]
        }
        """.data(using: .utf8)!
        let original = try decoder.decode(Skills.self, from: json)
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(Skills.self, from: encoded)
        #expect(decoded.count == original.count)
        #expect(decoded["Stealth"] != nil)
        #expect(decoded["History"] != nil)
    }

    // MARK: - Sequence extensions

    @Test("skills(from:) resolves skill names to Skill objects")
    func skillsFromNames() throws {
        let perception = Skill(name: "Perception", ability: .wisdom)
        let stealth = Skill(name: "Stealth", ability: .dexterity)
        let skills = Skills([perception, stealth])
        let resolved = try ["Perception", "Stealth"].skills(from: skills)
        #expect(resolved.count == 2)
        #expect(resolved.contains(where: { $0.name == "Perception" }))
        #expect(resolved.contains(where: { $0.name == "Stealth" }))
    }

    @Test("skills(from:) throws for unknown skill name")
    func skillsFromNamesThrows() {
        let skills = Skills([Skill(name: "Perception", ability: .wisdom)])
        #expect(throws: (any Error).self) {
            try ["UnknownSkill"].skills(from: skills)
        }
    }

    @Test("randomSkills(count:) returns requested number of unique skills")
    func randomSkillsCount() {
        let allSkills = [
            Skill(name: "Acrobatics", ability: .dexterity),
            Skill(name: "Athletics", ability: .strength),
            Skill(name: "Perception", ability: .wisdom),
            Skill(name: "Stealth", ability: .dexterity),
            Skill(name: "History", ability: .intelligence)
        ]
        let selected = allSkills.randomSkills(count: 3)
        #expect(selected.count == 3)
        for skill in selected {
            #expect(allSkills.contains(skill))
        }
    }

    @Test("randomSkills(count:) is capped at available skill count")
    func randomSkillsCountCapped() {
        let allSkills = [
            Skill(name: "Perception", ability: .wisdom),
            Skill(name: "Stealth", ability: .dexterity)
        ]
        let selected = allSkills.randomSkills(count: 10)
        #expect(selected.count == 2, "Cannot exceed available count")
    }

    @Test("skillNames returns array of skill name strings")
    func skillNames() {
        let skills = [
            Skill(name: "Arcana", ability: .intelligence),
            Skill(name: "Nature", ability: .intelligence)
        ]
        let names = skills.skillNames
        #expect(names.count == 2)
        #expect(names.contains("Arcana"))
        #expect(names.contains("Nature"))
    }

    @Test("Array append merges two skill arrays without duplicates")
    func arrayAppendSkills() {
        var a = [Skill(name: "Perception", ability: .wisdom), Skill(name: "Stealth", ability: .dexterity)]
        let b = [Skill(name: "Athletics", ability: .strength), Skill(name: "Perception", ability: .wisdom)]
        a.append(b)
        #expect(a.count == 3, "Perception should not be duplicated")
        #expect(a.contains(where: { $0.name == "Perception" }))
        #expect(a.contains(where: { $0.name == "Stealth" }))
        #expect(a.contains(where: { $0.name == "Athletics" }))
    }
}
