//
//  RapWheelScreen.swift
//  Rapchik
//
//  Created by Aravind Kumar on 03/12/25.
//

import SwiftUI
import Combine

struct RapWheelScreen: View {
    @StateObject private var vm = RapWheelViewModel(
        segments: [
            "person1", "person2", "person3", "person4",
            "person5", "person6", "person7", "person8",
            "person9", "person10", "person11", "person12"
        ],
        baseOffsetDegrees: 0   // tweak later if slice not exactly under pointer
    )
    
    @State private var isSpinning = false
    @State private var currentTargetIndex: Int = 3   // default index
    @State private var resultText: String = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Round label
                Text("ROUND 1")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                // Players row
                HStack(spacing: 24) {
                    playerCard(name: "YOU", points: 12, imageName: "person.crop.circle")
                    Text("VS")
                        .foregroundColor(.white)
                        .font(.headline)
                    playerCard(name: "KARAN", points: 0, imageName: "person.circle.fill")
                }
                .padding(.horizontal)
                
                Text("It's your turn now!")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
                    .padding(.bottom, 8)
                
                // Logo
                Text("RAP\nWHEEL")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 8)
                    .padding(.bottom, 4)
                
                // Wheel
                RapWheelView(viewModel: vm) {
                    spinWheel()
                }
                
                // Multipliers row
                HStack(spacing: 16) {
                    multiplierChip("1X",  color: .purple)
                    multiplierChip("1.5X", color: .yellow)
                    multiplierChip("2X",  color: .blue)
                    multiplierChip("2.5X", color: .green)
                }
                .padding(.top, 4)
                
                // Big bottom button
                Button(action: spinWheel) {
                    Text("SPIN THE WHEEL")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.green)
                                .shadow(radius: 6)
                        )
                        .padding(.horizontal, 32)
                }
                .disabled(isSpinning)
                .opacity(isSpinning ? 0.6 : 1.0)
                
                if !resultText.isEmpty {
                    Text(resultText)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Auto-spin on load to index 1
            DispatchQueue.main.async {
                currentTargetIndex = 1           // index you want on first load
                spinWheel()
            }
        }
    }
    
    private func spinWheel() {
        guard !isSpinning else { return }
        isSpinning = true
        
        // 👉 currentTargetIndex can be set before calling this (fixed or random)
        vm.spin(to: currentTargetIndex, duration: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isSpinning = false
            resultText = "Landed on index \(currentTargetIndex + 1)"
        }
    }
    
    // MARK: - Small helper views
    
    private func playerCard(name: String, points: Int, imageName: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
                Text("\(points) Pts")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private func multiplierChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color.opacity(0.9))
            )
    }
}
