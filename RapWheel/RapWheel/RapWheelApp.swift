//
//  RapWheelApp.swift
//  RapWheel
//
//  Created by Aravind Kumar on 04/12/25.
//

import SwiftUI

@main
struct RapWheelApp: App {
    var body: some Scene {
        WindowGroup {
            let vm = RapWheelViewModel(segments: [
            "person1", "person2", "person3", "person4",
            "person5", "person6", "person7", "person8",
            "person9", "person10", "person11", "person12"
        ])

        RapWheelView(
            viewModel: vm,
            onSpinTap: {
                // 👉 When SPIN button tapped, rotate and stop on index 3
                let randomIndex = Int.random(in: 1...11)
                vm.spin(to: randomIndex, duration: 3.1)            }
        )
        }
    }
}
