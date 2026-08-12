//
//  LabeledTextView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 1/3/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import SwiftUI

struct LabeledTextView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString(label, comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LabeledNumberView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString(label, comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            NumberView(number: value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Labeled Text") {
    VStack(spacing: 16) {
        LabeledTextView(label: "Background", value: "Folk Hero")
        LabeledTextView(label: "Species", value: "Dwarf")
        LabeledTextView(label: "Class", value: "Fighter")
    }
    .padding()
}

#Preview("Labeled Number") {
    HStack(spacing: 16) {
        LabeledNumberView(label: "Initiative", value: " +2 ")
        LabeledNumberView(label: "Speed", value: "30 ft")
        LabeledNumberView(label: "Armor Class", value: "15")
    }
    .padding()
}

