import SwiftUI

struct RapWheelView: View {
    @ObservedObject var viewModel: RapWheelViewModel
    var onSpinTap: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            // Use the smallest dimension (keep square)
            let size = min(geo.size.width, geo.size.height)
            
            // Wheel size (max 370)
            let wheelSize: CGFloat = min(size, 370)
            let wheelRadius = wheelSize / 2
            
            // Center of the geometry space
            let center = CGPoint(x: size / 2, y: size / 2)
            
            // Avatar ring + size
            let avatarSize: CGFloat = 40
            let ringRadius: CGFloat = wheelRadius - 40   // adjust for ring position
            
            ZStack {
                // MARK: - ROTATING WHEEL (image + avatars)
                ZStack {
                    // Wheel image
                    Image("Wheel_Options")
                        .resizable()
                        .scaledToFit()
                        .frame(width: wheelSize, height: wheelSize)
                        .position(center)
                    
                    // Avatars in circle
                    let count = viewModel.segments.count
                    
                    ForEach(0..<count, id: \.self) { i in
                        let angle = Double(i) / Double(count) * 360
                        let rad   = angle * (.pi / 180)
                        
                        Image(viewModel.segments[i])
                            .resizable()
                            .scaledToFill()
                            .frame(width: avatarSize, height: avatarSize)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .position(
                                x: center.x + ringRadius * CGFloat(cos(rad)),
                                y: center.y + ringRadius * CGFloat(sin(rad))
                            )
                    }
                }
                .frame(width: size, height: size)
                .rotationEffect(.degrees(viewModel.rotation))   // 🔥 only wheel rotates
                
                // MARK: - NON-ROTATING CENTER BUTTON
                Button(action: onSpinTap) {
                    Text("SPIN")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(24)
                        .background(
                            Circle()
                                .fill(Color.orange)
                                .shadow(radius: 10)
                        )
                }
                .position(center)
                
                // MARK: - NON-ROTATING POINTER AT TOP
                VStack {
                    Triangle()
                        .fill(Color.orange)
                        .frame(width: 36, height: 24)
                        .shadow(radius: 4)
                        .offset(y: -10)
                    Spacer()
                }
                .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Downward pointing triangle
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))        // bottom center
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))     // top right
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))     // top left
        p.closeSubpath()
        return p
    }
}
