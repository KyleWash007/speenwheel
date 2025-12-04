//
//  RapWheelViewModel.swift
//  Rapchik
//
//  Created by Aravind Kumar on 03/12/25.
//


import SwiftUI

final class RapWheelViewModel: ObservableObject {
    @Published var rotation: Double = 0       // in degrees
    let segments: [String]

    /// Offset to fix artwork orientation (if needed)
    /// e.g. if index 0 slice center is not exactly at 12 o'clock.
    let baseOffsetDegrees: Double

    init(segments: [String], baseOffsetDegrees: Double = 0) {
        self.segments = segments
        self.baseOffsetDegrees = baseOffsetDegrees
    }

    /// Spin wheel and stop so pointer is on given index (0 ..< segments.count)
    func spin(to index: Int, duration: Double = 3.0) {
        let count = segments.count
        guard count > 0 else { return }

        let safeIndex = max(0, min(index, count - 1))

        let anglePerSlice = 360.0 / Double(count)
        let fullRotations = 4.0        // number of full spins

        // Reset so math is stable each time
        rotation = 0

        // Pointer is fixed at top (0°).
        // We want the **center** of slice `safeIndex` under the pointer.
        let centerAngle = anglePerSlice * (Double(safeIndex) + 0.5)

        // Wheel rotates CCW (positive degrees). Content seen under pointer is -rotation.
        // So we rotate wheel to fullRotations*360 - centerAngle (+ optional baseOffset).
        print(baseOffsetDegrees)
        let finalRotation = fullRotations * 360.0
                           - centerAngle
                           + baseOffsetDegrees + 15

        withAnimation(.easeOut(duration: duration)) {
            self.rotation = finalRotation
        }
    }
}

