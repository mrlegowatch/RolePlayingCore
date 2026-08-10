//
//  FlowLayout.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 1/3/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import SwiftUI

// MARK: - Chip styling

private struct ChipStyle: ViewModifier {
    var backgroundOpacity: Double

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(backgroundOpacity))
            .clipShape(Capsule())
    }
}

extension View {
    func chipStyle(backgroundOpacity: Double = 0.1) -> some View {
        modifier(ChipStyle(backgroundOpacity: backgroundOpacity))
    }
}

// MARK: - Flow layout

/// A simple left-to-right wrapping layout for chip views.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
        }
        return CGSize(width: min(maxWidth, width), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
