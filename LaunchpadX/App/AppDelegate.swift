//
//  AppDelegate.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import Cocoa
class AppDelegate:NSObject, NSApplicationDelegate{
    func applicationDidFinishLaunching(_ notification:Notification){
        // .regular 普通 App（Dock + CmdTab）
        // .accessory 无 Dock，但可显示窗口
        // .prohibited 后台进程
        NSApp.setActivationPolicy(.accessory)
        GlobalKeyMonitor.shared.start()
        
        
        // 启动时直接显示
        WindowManager.shared.showLaunchpad()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        GlobalKeyMonitor.shared.stop()
    }
}
