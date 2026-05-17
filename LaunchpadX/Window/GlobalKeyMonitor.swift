//
//  GlobalKeyMonitor.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/13.
//
import AppKit
final class GlobalKeyMonitor {
    static let shared = GlobalKeyMonitor()
    // 改用保留底层 tap 的引用
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func start() {
        // 如果已经启动，先停掉
        stop()
        
        print("Starting CGEventTap monitor...")
        
        // 1. 定义事件回调
        let callback: CGEventTapCallBack = { _, type, event, _ in
            // 过滤按键按下事件
            if type == .keyDown {
                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                let flags = event.flags
                
                    
                print("Captured KeyCode: \(keyCode) with with flags: \(flags)")
                // 示例：A (KeyCode 0) 或 Option + Command + H
                let ACtrlAltShift = (keyCode == 0) && flags.contains([.maskShift,.maskControl,.maskAlternate])
                
                if ACtrlAltShift  {
                    DispatchQueue.main.async {
                        WindowManager.shared.toggleLaunchpad()
                    }
                    
                    // 如果你需要这个快捷键被你的应用独占，不传递给系统其他软件，这里可以返回 nil
                    return nil
                }
            }
            // 继续往下传递事件
            return Unmanaged.passRetained(event)
        }
        
        // 2. 创建 Tap (需要辅助功能或输入监控权限)
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: nil
        ) else {
            print("❌ 创建 CGEventTap 失败，请检查系统设置 > 隐私与安全性 > 辅助功能 是否勾选了本应用/Xcode")
            return
        }
        
        self.eventTap = tap
        
        // 3. 必须将 Tap 加入到主线程的 RunLoop 中，否则无法生效
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("✅ CGEventTap 成功运行，并挂载到主线程 RunLoop")
        }
    }

    func stop() {
        var isRunning = false
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            runLoopSource = nil
            isRunning = true
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
            isRunning = true
        }
        
        if isRunning {
            print("CGEventTap stopped.")
        }
    }
}
