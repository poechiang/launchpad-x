//
//  ScrollWheelGlobalMonitor.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/19.
//
import SwiftUI
import AppKit

struct LocalMonitorEvents: ViewModifier {
    let maxPages: Int
    @Binding var currentPageIndex: Int?
    
    class ScrollState {
        var lastScrollTime: Date = Date.distantPast
        var accumulatedDelta: CGFloat = 0
    }
    
    @State private var state = ScrollState()
    
    @Binding var searchText: String
    var isSearchBarFocused: FocusState<Bool>.Binding // 💡 引入搜索框焦点状态，用于智能防御
    var isBackgroundFocused: FocusState<Bool>.Binding // 💡 引入搜索框焦点状态，用于智能防御
    
    
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
                
                
                // 💡 核心魔法：直接在 AppKit 事件分发的最上游挂载键盘拦截器！
                // 这会在系统把按键发送给任何 SwiftUI 视图前强制截获它。
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    // 1. 防御防线：如果鼠标根本没在我们这个窗口内，放行
                    guard NSApp.keyWindow != nil && event.window == NSApp.keyWindow else { return event }
                    
                    // 2. 识别按键的关键码 (KeyCode)
                    let keyCode = event.keyCode
                    let flags = event.modifierFlags
                    
                    // 💡 A. 捕捉 ESC 键 (KeyCode 是 53)
                    if keyCode == 53 {
                        DispatchQueue.main.async {
                            WindowManager.shared.hideLaunchpad()
                        }
                        return nil // 完美拦截：返回 nil 宣告事件销毁，不向下传递
                    }
                    
                    // MARK: - 🛡️ 【白名单特赦一】：完美释放 Tab 键 (KeyCode 是 48)
                    if keyCode == 48 {
                        // 当用户在输入框内按 Tab 键，我们手动在两个焦点之间进行平滑轮转
                        DispatchQueue.main.async {
                            if isSearchBarFocused.wrappedValue {
                                isSearchBarFocused.wrappedValue = false
                                isBackgroundFocused.wrappedValue = true
                                
                            } else {
                                isSearchBarFocused.wrappedValue = true
                                isBackgroundFocused.wrappedValue = false
                            }
                        }
                        return nil 
                    }
                    
                    // MARK: - 🛡️ 【白名单特赦二】：捕获并硬核实现 Command + K
                    // k 的 KeyCode 是 40。检查修饰键是否包含了 .command
                    if keyCode == 40 && flags.contains(.command) {
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isSearchBarFocused.wrappedValue = true // 💡 强行对焦输入框
                                isBackgroundFocused.wrappedValue = false
                            }
                        }
                        return nil // 完美拦截：吞掉 Command + K，不让系统去别的地方瞎响应
                    }
                    
                    
                    // 💡 B. 捕捉方向键 (左方向键 KeyCode 是 123，右方向键 KeyCode 是 124)
                    if [116,121,123,124].contains(keyCode) {
                        // 【防御式编程一】：如果用户正在输入（输入框有焦点）且已经有了输入内容，
                        // 绝对不抢夺方向键，允许其在文本框内正常移动光标修改文字。
                        if [123,124].contains(keyCode) && !flags.contains(.command) && isSearchBarFocused.wrappedValue && !searchText.isEmpty {
                            return event // 放行：还给输入框
                        }
                        
                        // 否则（没字，或者输入框没焦点），方向键强行执行大网格切页
                        guard let currentIndex = currentPageIndex else { return event }
                        
                        DispatchQueue.main.async {
                            if [116,123].contains(keyCode) && currentIndex > 0 {
                                // ⬅️ 按左键
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    currentPageIndex = currentIndex - 1
                                }
                            } else if [121,124].contains(keyCode) && currentIndex < maxPages - 1 {
                                // ➡️ 按右键
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    currentPageIndex = currentIndex + 1
                                }
                            }
                        }
                        return nil // 完美拦截：吞掉硬件方向键
                    }
                    
                    return event // 其他普通按键（如字母、数字）放行，确保搜索框可以正常输入文字
                }
                            
            }
    }
}

// MARK: - 优雅的 View 扩展
extension View {
    func accelerateKeyboard(maxPages: Int, currentPageIndex: Binding<Int?>, searchText: Binding<String>, isSearchBarFocused: FocusState<Bool>.Binding,isBackgroundFocused: FocusState<Bool>.Binding) -> some View {
        self.modifier(LocalMonitorEvents(maxPages: maxPages, currentPageIndex: currentPageIndex, searchText: searchText, isSearchBarFocused: isSearchBarFocused,isBackgroundFocused: isBackgroundFocused))
    }
}
