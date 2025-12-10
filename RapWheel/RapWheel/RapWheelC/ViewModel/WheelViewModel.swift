//
//  WheelViewModel.swift
//  RapWheel
//
//  Created by Aravind Kumar on 04/12/25.
//

import SwiftUI

final class WheelViewModel: ObservableObject {
    // Data
    @Published var items: [WheelItem]
    @Published var rotation: Double = 0.0   // degrees
    
    // Config (ported)
    var rotationDirection: RotationDirection = .clockwise
    var rotateTime: Double = 5.0                  // seconds (5000ms)
    var rotateSpeed: RotationSpeed = .normal
    var rotateSpeedMultiplier: Double = 1.0
    var stopCenterOfItem: Bool = false
    
    // Text + icon configs (ported ideas)
    var textOrientation: TextOrientation = .horizontal
    var textPadding: CGFloat = 4
    var itemTextSize: CGFloat = 16
    var itemTextLetterSpacing: CGFloat = 0.1
    var textPositionFraction: CGFloat = 0.7
    var iconSizeMultiplier: CGFloat = 1.0
    var iconPositionFraction: CGFloat = 0.5
    
    // Stroke / center / separators
    var drawWheelStroke: Bool = false
    var wheelStrokeColors: [Color] = [.black]
    var wheelStrokeThickness: CGFloat = 4
    
    var drawItemSeparator: Bool = false
    var itemSeparatorColors: [Color] = [.black]
    var itemSeparatorThickness: CGFloat = 2
    
    var drawCenterPoint: Bool = false
    var centerPointColor: Color = .white
    var centerPointRadius: CGFloat = 40
    
    // Corner points
    var drawCornerPoints: Bool = false
    var cornerPointsEachSlice: Int = 1
    var cornerPointsColors: [Color] = []
    var useRandomCornerPointsColor: Bool = true
    var useCornerPointsGlowEffect: Bool = true
    var cornerPointsColorChangeSpeedMs: Int = 500
    var cornerPointsRadius: CGFloat = 10
    
    // Callbacks (WheelViewListener)
    var onRotationStatus: ((RotationStatus) -> Void)?
    var onRotationComplete: ((WheelItem) -> Void)?
    
    init(items: [WheelItem]) {
        self.items = items
    }
    
    // MARK: - Public API (rotate to known target index)
    func rotateToTarget(_ target: Int) {
        guard !items.isEmpty else { return }
        guard target >= 0 && target < items.count else {
            print("Wheel target out of range: \(target)")
            return
        }
        
        let angle = getRotationValueOfTarget(target: Double(target))
        
        onRotationStatus?(.rotating)
        
        withAnimation(.easeOut(duration: rotateTime)) {
            self.rotation = angle
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + rotateTime) { [weak self] in
            guard let self else { return }
            self.onRotationStatus?(.completed)
            self.onRotationComplete?(self.items[target])
        }
    }
    
    // MARK: - Random target (rotateWheelRandomTarget)
    func rotateRandomTarget() {
        guard !items.isEmpty else { return }
        let randomTarget = Int.random(in: 0..<items.count)
        rotateToTarget(randomTarget)
    }
    
    // MARK: - Reset (resetWheel)
    func reset() {
        onRotationStatus?(.idle)
        withAnimation(.none) {
            rotation = 0
        }
    }
    
    // MARK: - Core math (getRotationValueOfTarget)
    private func getRotationValueOfTarget(target: Double) -> Double {
        let count = items.count
        if count == 0 { return 0 }
        
        let sweep = 360.0 / Double(count)
        
        let spins: Double
        switch rotateSpeed {
        case .fast:
            spins = 15.0 * rotateSpeedMultiplier
        case .normal:
            spins = 10.0 * rotateSpeedMultiplier
        case .slow:
            spins = 1.0 * rotateSpeedMultiplier
        }
        
        // slice-center(i) = 270° + sweep * i  (top)
        let targetCenterAngle = 270.0 + sweep * target
        
        // rotation so that center aligns to 270°
        var desiredRotation = 270.0 - targetCenterAngle
        desiredRotation.formTruncatingRemainder(dividingBy: 360.0)
        if desiredRotation < 0 { desiredRotation += 360.0 }
        
        // random stop inside slice
        if !stopCenterOfItem {
            let half = sweep / 2.0
            let offset = Double.random(in: -half...half)
            desiredRotation = (desiredRotation + offset)
                .truncatingRemainder(dividingBy: 360.0)
            if desiredRotation < 0 { desiredRotation += 360.0 }
        }
        
        let fullSpins = 360.0 * spins
        
        switch rotationDirection {
        case .clockwise:
            return fullSpins + desiredRotation
        case .counterClockwise:
            return -(fullSpins + desiredRotation)
        }
    }
}
