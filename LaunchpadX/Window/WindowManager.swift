//
//  WindowManager.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import Cocoa

final class WindowManager {

    static let shared = WindowManager()
    private var launchpadWindow: LaunchpadWindow?
    
    
    private enum LaunchpadState{
        case hidden
        case showing
        case visible
        case hiding
    }
    
    private var state:LaunchpadState = .hidden
    
    func toggleLaunchpad(){
        switch state{
        case .hidden: showLaunchpad()
        case .visible: hideLaunchpad()
        default:break
        }
    }
    
    func showLaunchpad() {

        // 状态锁
        guard state == .hidden else{return}
        state = .showing
        
        if launchpadWindow == nil {
            launchpadWindow = LaunchpadWindow()
        }
        
        NSApp.presentationOptions=[.hideMenuBar,.hideDock]
        
        DispatchQueue.main.async {
            guard let window = self.launchpadWindow else { return }
            window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
            window.viewModel.scale = 0.92
        }
        
        launchpadWindow?.alphaValue = 0
        launchpadWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        Debugger.log("init")
        NSAnimationContext.runAnimationGroup({
        ctx in
            ctx.duration = 0.2
            self.launchpadWindow?.animator().alphaValue = 1
        },completionHandler: {
            self.state = .visible
            self.launchpadWindow?.viewModel.phase = .shown
            Debugger.log("ready")
        })

    }

    func hideLaunchpad() {
        // 状态锁
        guard state == .visible else { return }
        state = .hiding
        
        guard let window = launchpadWindow else { return }
        
        window.viewModel.scale = 1
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.18
            self.launchpadWindow?.animator().alphaValue = 0
        }, completionHandler: {
            window.orderOut(nil)
            NSApp.presentationOptions=[]
            self.state = .hidden
            window.viewModel.phase = .hidden
        })
    }
}
