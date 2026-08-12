//
//  CharacterBuilderView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

// Steps beyond the root (Species). Each value is pushed onto the NavigationStack path.
private enum BuilderStep: Hashable {
    case `class`, background, abilityScores, skills, spells, nameAndFinish
}

struct CharacterBuilderView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        // Guard against the brief window during dismissal when builderState
        // is set to nil before the animation completes.
        if let builderState = appState.builderState {
            BuilderStepContainer(builderState: builderState)
                .frame(minWidth: 400, minHeight: 600)
        }
    }
}

private struct BuilderStepContainer: View {
    @EnvironmentObject var appState: AppState
    @Bindable var builderState: CharacterBuilderState
    @State private var path: [BuilderStep] = []

    private var canAdvance: Bool { builderState.canAdvance(atStep: path.count) }

    private var isLastStep: Bool { path.last == .nameAndFinish }

    private var nextStep: BuilderStep? {
        switch path.count {
        case 0: return .class
        case 1: return .background
        case 2: return .abilityScores
        case 3: return .skills
        case 4: return builderState.isSpellcaster ? .spells : .nameAndFinish
        case 5 where builderState.isSpellcaster: return .nameAndFinish
        default: return nil
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            SpeciesPickerView(builderState: builderState)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: BuilderStep.self) { step in
                    stepView(for: step)
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .toolbar { builderToolbar }
                }
                .toolbar { builderToolbar }
                .onChange(of: builderState.selectedClass?.name) { _, newName in
                    guard let newName else { return }
                    builderState.classChanged(to: newName, using: appState.gameData)
                    // Pop back if class changed from spellcaster to non-spellcaster.
                    let maxDepth = builderState.totalSteps - 1
                    while path.count > maxDepth { path.removeLast() }
                }
                .onChange(of: builderState.selectedBackground?.name) { _, _ in
                    builderState.backgroundChanged()
                }
        }
    }

    @ToolbarContentBuilder
    private var builderToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) { leadingButton }
        ToolbarItem(placement: .principal) { progressView }
        ToolbarItem(placement: .topBarTrailing) { trailingButton }
    }

    @ViewBuilder
    private func stepView(for step: BuilderStep) -> some View {
        switch step {
        case .class:        ClassPickerView(builderState: builderState)
        case .background:   BackgroundPickerView(builderState: builderState)
        case .abilityScores: AbilityScoresBuilderView(builderState: builderState)
        case .skills:       SkillsPickerView(builderState: builderState)
        case .spells:       SpellsPickerView(builderState: builderState)
        case .nameAndFinish: NameAndFinishView(builderState: builderState)
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        if path.isEmpty {
            Button("Cancel") {
                appState.cancelBuildingCharacter()
            }
        } else {
            Button {
                path.removeLast()
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }
        }
    }

    private var progressView: some View {
        VStack(spacing: 3) {
            Text("\(path.count + 1) / \(builderState.totalSteps)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            ProgressView(value: Double(path.count + 1), total: Double(builderState.totalSteps))
                .progressViewStyle(ThickLinearProgressStyle())
                .frame(width: 220, height: 8)
        }
    }

    @ViewBuilder
    private var trailingButton: some View {
        if isLastStep {
            Button("Create") {
                appState.finalizeBuiltCharacter()
            }
            .disabled(!canAdvance)
            .fontWeight(.semibold)
        } else if let next = nextStep {
            Button {
                path.append(next)
            } label: {
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
            .disabled(!canAdvance)
        }
    }

}

private struct ThickLinearProgressStyle: ProgressViewStyle {
    func makeBody(configuration ctx: Configuration) -> some View {
        let fraction = ctx.fractionCompleted ?? 0
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.quaternary)
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: geo.size.width * fraction)
            }
        }
    }
}

#Preview {
    CharacterBuilderView()
        .environmentObject(AppState())
}
