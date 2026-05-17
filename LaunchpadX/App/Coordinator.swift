//
//  Coordinator.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/13.
//

import SwiftUI
import Combine

final class Coordinator: ObservableObject {

    @Published var isVisible: Bool = false

    func show() {
        print("is show")
        isVisible = true
    }

    func hide() {
        print("is hide")
        isVisible = false
    }

    func toggle() {
        isVisible.toggle()
    }
}
