//
//  FlowLayout.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom layout implementation that arranges subviews to fit available horizontal space.
//  Subviews are placed sequentially, wrapping to a new row when the container's width is exceeded.

import SwiftUI

/// A custom layout that arranges subviews in a flow-like manner.
struct FlowLayout: Layout {
    var spacing: CGFloat

    /// Initializes the FlowLayout with a specified spacing.
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let arranger = Arranger(
            containerSize: proposal.replacingUnspecifiedDimensions(),
            subviews: subviews,
            spacing: spacing
        )
        let result = arranger.arrange()
        return result.size
    }

    /// Places the subviews within the specified bounds and proposal.
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arranger = Arranger(
            containerSize: proposal.replacingUnspecifiedDimensions(),
            subviews: subviews,
            spacing: spacing
        )
        let result = arranger.arrange()

        for (index, cell) in result.cells.enumerated() {
            let point = CGPoint(
                x: bounds.minX + cell.frame.origin.x,
                y: bounds.minY + cell.frame.origin.y
            )

            subviews[index].place(
                at: point,
                anchor: .topLeading,
                proposal: ProposedViewSize(cell.frame.size)
            )
        }
    }
}

/// A structure that handles the arrangement of subviews in a flow layout.
private struct Arranger {
    var containerSize: CGSize
    var subviews: LayoutSubviews
    var spacing: CGFloat

    /// Initializes the Arranger with the container size, subviews, and spacing.
    func arrange() -> Result {
        var cells: [Cell] = []

        var maxY: CGFloat = 0
        var previousFrame: CGRect = .zero

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize(containerSize))

            var origin: CGPoint
            if index == 0 {
                origin = .zero
            } else if previousFrame.maxX + spacing + size.width > containerSize.width {
                origin = CGPoint(x: 0, y: maxY + spacing)
            } else {
                origin = CGPoint(x: previousFrame.maxX + spacing, y: previousFrame.minY)
            }

            let frame = CGRect(origin: origin, size: size)
            let cell = Cell(frame: frame)
            cells.append(cell)

            previousFrame = frame
            maxY = max(maxY, frame.maxY)
        }

        let maxWidth = cells.reduce(0, { max($0, $1.frame.maxX) })
        return Result(
            size: CGSize(width: maxWidth, height: previousFrame.maxY),
            cells: cells
        )
    }
}

/// A structure that represents the result of arranging subviews in a flow layout.
private struct Result {
    var size: CGSize
    var cells: [Cell]
}

/// A structure that represents a cell in the flow layout.
private struct Cell {
    var frame: CGRect
}
