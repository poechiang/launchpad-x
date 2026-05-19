//
//  ScrollWheelGlobalMonitor.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/19.
//
import SwiftUI
import AppKit

struct ScrollWheelGlobalMonitor: ViewModifier {
    let maxPages: Int
    @Binding var currentPageIndex: Int?
    
    class ScrollState {
        var lastScrollTime: Date = Date.distantPast
        var accumulatedDelta: CGFloat = 0
    }
    
    @State private var state = ScrollState()
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    // 💡 1. 核心改进：获取当前应用的主窗口（只要窗口目前在屏幕上显示着，window 就不为 nil）
                    guard let appWindow = event.window else { return event }
                    
                    // 💡 2. 核心改进：获取当前鼠标指针在整个 Mac 屏幕上的【绝对物理坐标】
                    let mouseLocation = NSEvent.mouseLocation
                    
                    // 💡 3. 终极悬停校验：直接用数学方法，判断当前鼠标的坐标是否【包含】在当前应用窗口的 Frame 范围内！
                    // 这就彻底摆脱了 keyWindow 的限制，只要鼠标悬停在 Launchpad 上，哪怕它没有获得焦点，也绝对管用
                    guard appWindow.frame.contains(mouseLocation) else {
                        return event // 如果鼠标滑出了 Launchpad 范围，放行事件给系统其他软件
                    }
                    // 4. 特征剔除：如果是苹果官方触控板，放行让其跑纯 SwiftUI 原生 3D 动画
//                    if !event.phase.isEmpty || !event.momentumPhase.isEmpty { return event }
                    
                    let deltaX = event.deltaX
//                    guard abs(deltaX) > 0.1 else { return event }
                    
                    let now = Date()
                    // 5. 同步安全冷却锁
                    guard now.timeIntervalSince(state.lastScrollTime) > 0.45 else {
                        return nil // 冷却期吞掉，防鬼畜
                    }
                                   
                    
                    if let currentIndex = currentPageIndex {
                        if currentIndex <= 0 && deltaX > 0 || currentIndex >= maxPages-1 && deltaX < 0{
                            return event
                        }
                    }
                    
                    state.accumulatedDelta += deltaX
                    let threshold: CGFloat = 24.0 // 灵敏度阈值
                    if abs(state.accumulatedDelta) >= threshold {
                        state.lastScrollTime = now
                        let isScrollLeft = state.accumulatedDelta > 0
                        state.accumulatedDelta = 0 // 同步就地重置
                        
                        DispatchQueue.main.async {
                            if let currentIndex = currentPageIndex {
                                if isScrollLeft && currentIndex > 0 {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                        currentPageIndex = currentIndex - 1
                                    }
                                } else if !isScrollLeft && currentIndex < maxPages - 1 {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                        currentPageIndex = currentIndex + 1
                                    }
                                }
                            }
                        }
                        
                        return nil // 完美就地销毁当前鼠标硬滚轮事件
                    }
                    
                    return event
                }
            }
    }
}

// MARK: - 优雅的 View 扩展
extension View {
    func accelerateMouseWheel(maxPages: Int, currentPageIndex: Binding<Int?>) -> some View {
        return self.modifier(ScrollWheelGlobalMonitor(maxPages: maxPages, currentPageIndex: currentPageIndex))
    }
}
