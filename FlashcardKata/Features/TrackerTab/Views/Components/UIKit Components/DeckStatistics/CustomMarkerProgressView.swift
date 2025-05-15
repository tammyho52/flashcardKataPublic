//
//  CustomMarkerProgressView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom view that displays a progress bar with a marker and percentage label.

import UIKit
import SwiftUI

/// A custom progress view that represents flashcard review progress.
class CustomMarkerProgressView: UIView {
    // MARK: - Private UI Components
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var markerView: HexagonView?
    private var percentLabel: UILabel?
    
    // MARK: - Configuration Properties
    private var progress: CGFloat
    private var progressColor: UIColor
    private var markerColor: UIColor = Color.customAccent3.uiColor
    private let height: CGFloat = 30
    
    // MARK: - Initializers
    init(frame: CGRect, progress: CGFloat, progressColor: UIColor) {
        self.progress = progress
        self.progressColor = progressColor
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError(uiKitFatalErrorMessage(for: "CustomMarkerProgressView"))
    }
    
    // MARK: - Setup Methods
    private func setupLayers() {
        setupTrackLayer()
        setupProgressLayer()
        setupMarkerView()
        setupPercentLabel()
    }
    
    /// Sets up the background track layer of the progress view.
    private func setupTrackLayer() {
        trackLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: height), cornerRadius: height / 2).cgPath
        trackLayer.fillColor = Color.customLightGray.uiColor.withAlphaComponent(0.5).cgColor
        trackLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        trackLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        trackLayer.position = CGPoint(x: 0, y: height / 2)
        layer.addSublayer(trackLayer)
    }
    
    /// Sets up the foreground progress layer of the progress view.
    private func setupProgressLayer() {
        progressLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width * progress, height: height), cornerRadius: height / 2).cgPath
        progressLayer.fillColor = progressColor.cgColor
        progressLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        progressLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressLayer.position = CGPoint(x: 0, y: height / 2)
        layer.addSublayer(progressLayer)
    }
    
    /// Sets up the marker view that indicates the current progress.
    private func setupMarkerView() {
        markerView = HexagonView(
            frame: CGRect(
                x: bounds.width * progress - (height / 2),
                y: (-height * 0.3) / 2,
                width: height * 1.3,
                height: height * 1.3
            ),
            size: height + 10,
            fillColor: markerColor
        )
        markerView?.layer.zPosition = 1
        if let markerView {
            addSubview(markerView)
        }
    }
    
    /// Sets up the percentage label that displays the current progress percentage.
    private func setupPercentLabel() {
        percentLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        percentLabel?.text = String(format: "%.0f%%", progress * 100)
        percentLabel?.textAlignment = .center
        percentLabel?.textColor = .black
        percentLabel?.font = .systemFont(ofSize: 11, weight: .medium)
        if let markerView {
            percentLabel?.center = CGPoint(x: markerView.frame.midX, y: markerView.frame.midY)
        }
        percentLabel?.layer.zPosition = 2
        if let percentLabel {
            addSubview(percentLabel)
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update track and progress paths based on the new progress
        trackLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: height), cornerRadius: height / 2).cgPath
        
        progressLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width * progress, height: height), cornerRadius: height / 2).cgPath
        progressLayer.fillColor = progressColor.cgColor
        progressLayer.bounds = CGRect(x: 0, y: 0, width: bounds.width / 2, height: height)
        
        // Update marker position and label
        guard let markerView else { return }
        markerView.frame.origin.x = max(0, bounds.width * progress - 30)
        
        percentLabel?.text = String(format: "%.0f%%", progress * 100)
        percentLabel?.center = CGPoint(x: markerView.frame.midX, y: markerView.frame.midY)
    }
    
    /// Updates the progress of the view.
    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0, min(1, value))
        self.progress = clampedProgress
        
        let newWidth = bounds.width * clampedProgress
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = progressLayer.bounds.width
        animation.toValue = newWidth
        animation.duration = animated ? 0.3 : 0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        progressLayer.bounds.size.width = newWidth
        progressLayer.add(animation, forKey: "progress")
        
        setNeedsLayout()
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

struct CustomMarkerProgressViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CustomMarkerProgressView {
        return CustomMarkerProgressView(frame: CGRect(x: 0, y: 0, width: 300, height: 30), progress: 1, progressColor: .darkBlue)
    }
    
    func updateUIView(_ uiView: CustomMarkerProgressView, context: Context) {
        // Empty
    }
}

#Preview {
    VStack {
        Spacer()
        CustomMarkerProgressViewRepresentable()
        Spacer()
    }
}
#endif
