//
//  LaunchpadXApp.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import SwiftUI

@main
struct LaunchpadXApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    init(){
        swizzleMenuAccessibility()
    }
    var body: some Scene {
        Settings{
            EmptyView()
        }
    }
}
