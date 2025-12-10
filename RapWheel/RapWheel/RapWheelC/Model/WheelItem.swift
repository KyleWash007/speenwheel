//
//  WheelItem.swift
//  RapWheel
//
//  Created by Aravind Kumar on 04/12/25.
//


import SwiftUI

// MARK: - Enums (Android constants → Swift)

enum RotationDirection {
    case clockwise
    case counterClockwise
}

enum RotationSpeed {
    case fast
    case normal
    case slow
}

enum RotationStatus {
    case idle
    case rotating
    case completed
    case canceled
}

enum TextOrientation {
    case horizontal
    case vertical
    case verticalToCenter
    case verticalToCorner
}

// MARK: - Wheel item (Swift equivalent of WheelData)

struct WheelItem {
    var text: String
    var backgroundColors: [Color]      // Android: intArray backgroundColor
    var textColors: [Color]           // Android: intArray textColor
    var iconName: String?             // use asset name (instead of Bitmap)
    var font: Font?                   // similar to Typeface
}
