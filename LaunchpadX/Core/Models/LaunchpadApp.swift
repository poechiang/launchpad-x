//
//  LaunchpadApp.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/11.
//

import AppKit

struct LaunchpadApp: Identifiable, Hashable {

    let id = UUID()
    
    let bundleId:String
    
    let isSystemApp:Bool

    let name: String

    let icon: NSImage
    
    let iconCacheKey: String?

    let url: URL

    /// Launchpad需要的UI状态（后面分页/动画用）
    var isHidden: Bool = false
}
