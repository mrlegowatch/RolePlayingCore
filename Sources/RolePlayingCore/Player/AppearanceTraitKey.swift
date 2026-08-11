//
//  AppearanceTraitKey.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A key for a trait in a `PlayerAppearance` dictionary.
///
/// The backing store is always `[String: String]`, so any additional key can be stored
/// freely — these constants supply a shared vocabulary and enable builder UIs to
/// enumerate known fields via `allStandardKeys`.
///
/// Extend this type to define additional keys:
/// ```swift
/// extension AppearanceTraitKey {
///     static let tattoo = AppearanceTraitKey("tattoo")
/// }
/// ```
public struct AppearanceTraitKey: Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public static let hairColor = AppearanceTraitKey("hair color")
    public static let eyeColor  = AppearanceTraitKey("eye color")
    public static let skinColor = AppearanceTraitKey("skin color")
    public static let age       = AppearanceTraitKey("age")
    public static let birthdate = AppearanceTraitKey("birthdate")
    public static let gender    = AppearanceTraitKey("gender")
    public static let height    = AppearanceTraitKey("height")

    /// All keys defined by the library, for use in builder UIs.
    public static let allStandardKeys: [AppearanceTraitKey] = [
        .hairColor, .eyeColor, .skinColor, .age, .birthdate, .gender, .height
    ]
}
