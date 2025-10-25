//
//  Initiative.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/25/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

struct Initiative {
    let player: Player
    var value: Int
    
    public enum Surprise {
        case normal, advantage, disadvantage
        var bonus: Int { (self == .advantage) ? 5 : (self == .disadvantage) ? -5 : 0 }
    }

    init(_ player: Player, roll: Bool = false, surprise: Surprise = .normal) {
        self.player = player
        value = (roll ? Die.d20.roll() : 10) + player.initiativeModifier + surprise.bonus
    }
}

extension Initiative: Comparable {
    public static func < (lhs: Initiative, rhs: Initiative) -> Bool {
        lhs.value < rhs.value
    }
}
