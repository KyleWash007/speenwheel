//
//  LuckyWheelView.swift
//  RapWheel
//
//  Created by Aravind Kumar on 04/12/25.
//

import SwiftUI

struct LuckyWheelView: View {
    @ObservedObject var viewModel: WheelViewModel
    
    /// Called when icon tapped (like onIconClick)
    var onIconTap: ((Int) -> Void)?
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2
            
            ZStack {
                // MARK: - Canvas wheel (slices, stroke, separators, center, corner points)
                Canvas { context, canvasSize in
                    let canvasCenter = CGPoint(x: canvasSize.width / 2,
                                               y: canvasSize.height / 2)
                    let minSide = min(canvasSize.width, canvasSize.height)
                    let wheelRadius = minSide / 2
                    
                    drawWheelBackground(in: &context,
                                        center: canvasCenter,
                                        radius: wheelRadius)
                    
                    drawWheelStroke(in: &context,
                                    center: canvasCenter,
                                    radius: wheelRadius)
                    
                    drawWheelItems(in: &context,
                                   size: canvasSize,
                                   center: canvasCenter,
                                   radius: wheelRadius)
                    
                    drawItemSeparator(in: &context,
                                      center: canvasCenter,
                                      radius: wheelRadius)
                    
                    drawCornerPoints(in: &context,
                                     center: canvasCenter,
                                     radius: wheelRadius)
                    
                    drawCenterPoint(in: &context,
                                    center: canvasCenter)
                }
                .frame(width: size, height: size)
                .rotationEffect(.degrees(viewModel.rotation))   // same as Android View.rotation()
                
                // MARK: - Icons (hit-testable SwiftUI views)
                let count = viewModel.items.count
                if count > 0 {
                    ForEach(0..<count, id: \.self) { index in
                        let sweep = 360.0 / Double(count)
                        // slice center (same logic as Kotlin drawWheelItems)
                        let startAngle = 270.0 - sweep / 2.0
                        let iconCenterAngle = startAngle + sweep * Double(index)
                        let rad = iconCenterAngle * .pi / 180
                        
                        let iconRadius = radius * viewModel.iconPositionFraction
                        let x = iconRadius * cos(rad)
                        let y = iconRadius * sin(rad)
                        
                        if let name = viewModel.items[index].iconName {
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 36 * viewModel.iconSizeMultiplier,
                                    height: 36 * viewModel.iconSizeMultiplier
                                )
                                .clipShape(Circle())
                                .contentShape(Circle())
                                .offset(x: x, y: y)
                                // Wheel is rotated, but view hierarchy rotates together,
                                // so taps still work visually.
                                .onTapGesture {
                                    onIconTap?(index)
                                }
                        }
                    }
                    .rotationEffect(.degrees(viewModel.rotation)) // match canvas rotation
                }
            }
            .frame(width: size, height: size)
        }
    }
}
extension LuckyWheelView {
    // MARK: - Background (drawWheelBackground)
    private func drawWheelBackground(
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let path = Path { p in
            p.addArc(center: center,
                     radius: radius,
                     startAngle: .degrees(0),
                     endAngle: .degrees(360),
                     clockwise: false)
        }
        
        context.fill(path, with: .color(.black))
    }
    
    // MARK: - Stroke (drawWheelStroke)
    private func drawWheelStroke(
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        guard viewModel.drawWheelStroke else { return }
        
        let outerRadius = radius
        let lineWidth = viewModel.wheelStrokeThickness
        
        let path = Path { p in
            p.addArc(center: center,
                     radius: outerRadius - lineWidth / 2,
                     startAngle: .degrees(0),
                     endAngle: .degrees(360),
                     clockwise: false)
        }
        
        let strokeColor: Color =
            viewModel.wheelStrokeColors.first ?? .black
        
        context.stroke(path,
                       with: .color(strokeColor),
                       lineWidth: lineWidth)
    }
    
    // MARK: - Items (drawWheelItems)
    private func drawWheelItems(
        in context: inout GraphicsContext,
        size: CGSize,
        center: CGPoint,
        radius: CGFloat
    ) {
        let items = viewModel.items
        let count = items.count
        guard count > 0 else { return }
        
        let sweep = 360.0 / Double(count)
        var startAngle = 270.0 - sweep / 2.0   // 0th slice centered at top
        
        for item in items {
            // 1) Slice background
            let slicePath = Path { p in
                p.addArc(center: center,
                         radius: radius,
                         startAngle: .degrees(startAngle),
                         endAngle: .degrees(startAngle + sweep),
                         clockwise: false)
                p.addLine(to: center)
                p.closeSubpath()
            }
            
            let bgColors = item.backgroundColors.isEmpty ? [Color.black] : item.backgroundColors
            let bg: GraphicsContext.Shading =
                bgColors.count == 1
                ? .color(bgColors[0])
                : .radialGradient(
                    Gradient(colors: bgColors),
                    center: center,
                    startRadius: 0,
                    endRadius: radius
                )

            context.fill(slicePath, with: bg)

            
            // 2) Text along arc / at center (simplified vs. multiple orientations)
            drawItemText(
                item: item,
                in: &context,
                center: center,
                radius: radius,
                startAngle: startAngle,
                sweep: sweep
            )
            
            startAngle += sweep
        }
    }
    
    private func drawItemText(
        item: WheelItem,
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        startAngle: Double,
        sweep: Double
    ) {
        let midAngle = startAngle + sweep / 2.0
        let rad = midAngle * .pi / 180
        let textR = radius * viewModel.textPositionFraction
        let x = center.x + textR * CGFloat(cos(rad))
        let y = center.y + textR * CGFloat(sin(rad))
        
        let textColor = item.textColors.first ?? .white
        let resolvedFont = item.font ?? .system(size: viewModel.itemTextSize)
        
        let text = Text(item.text)
            .font(resolvedFont)
            .foregroundColor(textColor)
        
        let point = CGPoint(x: x, y: y)
        
        switch viewModel.textOrientation {
        case .horizontal:
            context.draw(text, at: point, anchor: .center)

        case .vertical, .verticalToCenter, .verticalToCorner:
            let rotation = viewModel.textOrientation == .verticalToCenter
                ? midAngle + 180
                : midAngle

            // Rotate around text point
            context.translateBy(x: point.x, y: point.y)
            context.rotate(by: .degrees(rotation))
            context.translateBy(x: -point.x, y: -point.y)

            context.draw(text, at: point, anchor: .center)
        }
    }

    
    // MARK: - Separators (drawItemSeparator)
    private func drawItemSeparator(
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        guard viewModel.drawItemSeparator else { return }
        
        let items = viewModel.items
        let count = items.count
        guard count > 0 else { return }
        
        let sweep = 360.0 / Double(count)
        let sepColor = viewModel.itemSeparatorColors.first ?? .black
        
        for i in 0..<count {
            let angle = Double(i) * sweep
            let rad = angle * .pi / 180
            
            let endX = center.x + radius * CGFloat(cos(rad))
            let endY = center.y + radius * CGFloat(sin(rad))
            
            var path = Path()
            path.move(to: center)
            path.addLine(to: CGPoint(x: endX, y: endY))
            
            context.stroke(path,
                           with: .color(sepColor),
                           lineWidth: viewModel.itemSeparatorThickness)
        }
    }
    
    // MARK: - Corner points (drawCornerPoints)
    private func drawCornerPoints(
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        guard viewModel.drawCornerPoints else { return }
        
        let count = viewModel.items.count
        guard count > 0 else { return }
        
        let pointsOnCircle = count + (count * viewModel.cornerPointsEachSlice)
        guard pointsOnCircle > 0 else { return }
        
        let angleStep = (2 * Double.pi / Double(pointsOnCircle))
        
        let baseColors =
            viewModel.cornerPointsColors.isEmpty ? [Color.white] : viewModel.cornerPointsColors
        
        for i in 0..<pointsOnCircle {
            let angle = Double(i) * angleStep
            let r = radius - viewModel.cornerPointsRadius * 2
            let x = center.x + r * CGFloat(cos(angle))
            let y = center.y + r * CGFloat(sin(angle))
            
            let color: Color =
                viewModel.useRandomCornerPointsColor
                ? baseColors.randomElement() ?? .white
                : baseColors.first ?? .white
            
            let pointPath = Path { p in
                p.addArc(center: CGPoint(x: x, y: y),
                         radius: viewModel.cornerPointsRadius,
                         startAngle: .degrees(0),
                         endAngle: .degrees(360),
                         clockwise: false)
            }
            
            if viewModel.useCornerPointsGlowEffect {
                let glowPath = Path { p in
                    p.addArc(center: CGPoint(x: x, y: y),
                             radius: viewModel.cornerPointsRadius * 1.5,
                             startAngle: .degrees(0),
                             endAngle: .degrees(360),
                             clockwise: false)
                }
                context.fill(glowPath, with: .color(color.opacity(0.4)))
            }
            
            context.fill(pointPath, with: .color(color))
        }
    }
    
    // MARK: - Center point (drawCenterPoint)
    private func drawCenterPoint(
        in context: inout GraphicsContext,
        center: CGPoint
    ) {
        guard viewModel.drawCenterPoint else { return }
        
        let path = Path { p in
            p.addArc(center: center,
                     radius: viewModel.centerPointRadius,
                     startAngle: .degrees(0),
                     endAngle: .degrees(360),
                     clockwise: false)
        }
        
        context.fill(path, with: .color(viewModel.centerPointColor))
    }
}
