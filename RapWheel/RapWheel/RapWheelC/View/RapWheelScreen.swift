//
//  RapWheelScreen.swift
//  Rapchik
//
//  Created by Aravind Kumar on 03/12/25.
//

import SwiftUI
import Combine

struct RapWheelScreen: View {
    @StateObject private var vm = WheelViewModel(
        items: [
            WheelItem(
                text: "Person 1",
                backgroundColors: [.red, .orange],
                textColors: [.white],
                iconName: "person1",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 2",
                backgroundColors: [.blue, .purple],
                textColors: [.white],
                iconName: "person2",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 3",
                backgroundColors: [.green, .mint],
                textColors: [.white],
                iconName: "person3",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 4",
                backgroundColors: [.pink, .red],
                textColors: [.white],
                iconName: "person4",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 5",
                backgroundColors: [.indigo, .blue],
                textColors: [.white],
                iconName: "person5",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 6",
                backgroundColors: [.orange, .yellow],
                textColors: [.white],
                iconName: "person6",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 7",
                backgroundColors: [.purple, .pink],
                textColors: [.white],
                iconName: "person7",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 8",
                backgroundColors: [.teal, .green],
                textColors: [.white],
                iconName: "person8",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 9",
                backgroundColors: [.brown, .orange],
                textColors: [.white],
                iconName: "person9",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 10",
                backgroundColors: [.cyan, .blue],
                textColors: [.white],
                iconName: "person10",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 11",
                backgroundColors: [.yellow, .orange],
                textColors: [.white],
                iconName: "person11",
                font: .system(size: 14, weight: .bold)
            ),
            WheelItem(
                text: "Person 12",
                backgroundColors: [.gray, .purple],
                textColors: [.white],
                iconName: "person12",
                font: .system(size: 14, weight: .bold)
            )
        ]
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
                
                // MARK: - Lucky Wheel with pointer + center SPIN
                ZStack {
                    LuckyWheelView(viewModel: vm) { tappedIndex in
                        // icon tapped
                        print("Icon tapped at index: \(tappedIndex)")
                    }
                    .frame(width: 320, height: 320)
                    
                    // Fixed pointer at top
                    VStack {
                        Triangle()
                            .fill(Color.orange)
                            .frame(width: 36, height: 24)
                            .shadow(radius: 4)
                            .padding(.top, -10)
                        Spacer()
                    }
                    .frame(width: 320, height: 320)
                    
                    // Center SPIN button
                    Button(action: spinWheel) {
                        Text("SPIN")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(Color.orange)
                                    .shadow(radius: 8)
                            )
                    }
                    .disabled(isSpinning)
                    .opacity(isSpinning ? 0.6 : 1.0)
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
            // Config same as Android defaults
            vm.rotationDirection = .clockwise
            vm.rotateSpeed = .normal
            vm.rotateSpeedMultiplier = 1.0
            
            vm.onRotationComplete = { item in
                // you can show person name instead of index
                resultText = "Landed on \(item.text)"
            }
            
            // Auto-spin on load to index 1
            DispatchQueue.main.async {
                currentTargetIndex = 1
                spinWheel()
            }
        }
    }
    
    // MARK: - Spin logic (uses LuckyWheelViewModel)
    private func spinWheel() {
        guard !isSpinning else { return }
        isSpinning = true
        
        vm.rotateTime = 3.0                        // seconds
        vm.rotateToTarget(currentTargetIndex)      // uses Android-like math
        
        DispatchQueue.main.asyncAfter(deadline: .now() + vm.rotateTime) {
            isSpinning = false
            // If you want index-based text instead of item.text:
            // resultText = "Landed on index \(currentTargetIndex + 1)"
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
