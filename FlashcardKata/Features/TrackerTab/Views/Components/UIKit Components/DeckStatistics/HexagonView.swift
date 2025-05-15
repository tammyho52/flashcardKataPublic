//
//  HexagonView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom UIView that draws a hexagon shape and fills it with a specified color.

import UIKit

/// A UIView that draws a hexagon shape and fills it with a specified color, used for progress views.
class HexagonView: UIView {
    // MARK: - Properties
    private var hexagonPath: UIBezierPath? // Cache the hexagon path for performance
    
    var size: CGFloat
    var fillColor: UIColor
    
    // MARK: - Initializers
    init(frame: CGRect, size: CGFloat, fillColor: UIColor) {
        self.size = size
        self.fillColor = fillColor
        super.init(frame: frame)
        self.layer.contentsScale = UIScreen.main.scale
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError(uiKitFatalErrorMessage(for: "HexagonView"))
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Create the hexagon path only once and cache it
        if hexagonPath == nil {
            hexagonPath = createHexagonPath()
        }
        
        fillColor.setFill()
        hexagonPath?.fill()
    }
    
    // MARK: - Private Methods
    private func createHexagonPath() -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let angleOffset: CGFloat = .pi / 6
        let numberOfSides: CGFloat = 6
        let radius = size / 2
        
        for i in 0..<Int(numberOfSides) {
            let angle = angleOffset + (CGFloat(i) * (2 * .pi / numberOfSides))
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.close()
        return path
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    HexagonView(
        frame: CGRect(x: 0, y: 0, width: 200, height: 200),
        size: 200,
        fillColor: .blue
    )
}
#endif
