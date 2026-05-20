//
//  LaunchpadViewModel.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import SwiftUI
import CoreGraphics
import Combine

final class LaunchpadViewModel: ObservableObject {
    
    
    enum LaunchpadPhase{
        case hidden
        case shown
    }
    
    @Published var scale: CGFloat = 1
    @Published var screenFingerprint: String = "init"
    @Published var phase: LaunchpadPhase = .hidden
    
    @Published var apps: [LaunchpadApp] = []
    init() {
        loadApps()
    }

    func loadApps() {
        apps = AppScanner.loadApplications()
    }
}
