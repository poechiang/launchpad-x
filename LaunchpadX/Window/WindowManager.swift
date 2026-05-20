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
        
        let window = NSApp.windows.first(where: { $0.isOpaque == false })
        // 1. 获取当前窗口所在的物理显示器
        guard let currentScreen = window?.screen ?? NSScreen.main else { return }
        
        let fullFrame = currentScreen.frame          // 物理全屏 (包含菜单栏和 Dock)
        let visibleFrame = currentScreen.visibleFrame // 可见全屏 (扣除了菜单栏和 Dock)
        
        let width = fullFrame.size.width
        let height = fullFrame.size.height
        
        // 2. 多屏动态差值算法：检测 Dock 是否在当前这个窗口所在的屏幕驻留
        let hasDockOnThisScreen = (height - visibleFrame.size.height > 30) || (width - visibleFrame.size.width > 0)
        
        
        NSApp.presentationOptions=[.hideMenuBar,.hideDock]
        
        if hasDockOnThisScreen {
            NSApp.presentationOptions = [.hideDock, .hideMenuBar]
            
            Debugger.log("🖥️ 状态：【有Dock屏幕】-> 已开启官方阻断，Dock鼠标悬停彻底失效")
        } else {
            // 🔵 情况 B：当前处于【干净的副屏幕（无 Dock 驻留）】！
            // 💡 关键成功：我们【完全不向系统申请任何 presentationOptions 改变】，保持全进程的和平。
            // 这样副屏的菜单栏依然保留，且副屏的用户可以正常操作，完全不受我们软件的干扰。
            NSApp.presentationOptions = []
            
            // 窗口精准切为可见安全区域
            Debugger.log("🖥️ 状态：【无Dock副屏】-> 全进程放行，保持副屏菜单栏完全外露交互")
        }
        
        let newFingerprint = "screen_\(Int(width))_\(Int(height))"
        
        
        
        DispatchQueue.main.async {
            guard let window = self.launchpadWindow else { return }
            window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
            window.viewModel.scale = 0.92
            
            if window.viewModel.screenFingerprint != newFingerprint {
                Debugger.log("🖥️ 监测到横竖屏/多屏切换，指纹更新为: \(newFingerprint)，已强制擦除布局缓存")
                window.viewModel.screenFingerprint = newFingerprint
            }
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
