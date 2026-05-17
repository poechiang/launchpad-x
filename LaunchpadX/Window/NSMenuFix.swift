//
//  NSMenuFix.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/16.
//

import AppKit

// 1. 为 NSMenu 动态添加一个安全接住辅助功能调用的方法
extension NSMenu {
    @objc func safeAccessibilityPerformAction(_ action: Any) -> Bool {
        // 静默吞掉系统的错发，返回 false 阻止崩溃
        return false
    }
}

// 2. 运行时方法交换逻辑
func swizzleMenuAccessibility() {
    let originalSelector = NSSelectorFromString("accessibilityPerformAction:")
    let swizzledSelector = #selector(NSMenu.safeAccessibilityPerformAction(_:))
    
    guard let originalMethod = class_getInstanceMethod(NSMenu.self, originalSelector),
          let swizzledMethod = class_getInstanceMethod(NSMenu.self, swizzledSelector) else {
        return
    }
    
    method_exchangeImplementations(originalMethod, swizzledMethod)
    print("🚀 针对隐藏菜单栏的 NSMenu 运行时防御已注入！")
}
