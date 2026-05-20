//
//  GridView.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/17.
//
import SwiftUI

struct PageModel: Identifiable, Hashable {
    let id: Int
    let apps: [LaunchpadApp]
}

struct GridView: View {
    @ObservedObject var viewModel: LaunchpadViewModel
    @State private var hoveredAppId: UUID?
    
    @State private var rowCount = 5
    @State private var rowSpacing:CGFloat = 30
    @State private var columnCount = 8
    @State private var columnSpacing:CGFloat = 40
    
    @Environment(\.hideLaunchpad)
    private var hideLaunchpad
    
    @State private var currentPageIndex: Int? = 0
    
    @State private var searchText: String = ""
    
    private var filteredPages: [PageModel] {
        let filteredApps = viewModel.apps.filter { app in
            searchText.isEmpty ? true:app.name.localizedCaseInsensitiveContains(searchText)
        }
        
        let chunked = filteredApps.chunked(into: 32)
        
        return chunked.enumerated().map {
            PageModel(id: $0.offset, apps: $0.element)
        }
    }
    
    
    // 💡 核心新增：捕获当前的系统主题（.light 或 .dark）
    @Environment(\.colorScheme) var colorScheme
    
    
    
    // 💡 1. 核心新增：专门用来接收键盘方向键事件的焦点状态
    @FocusState private var isBackgroundFocused: Bool;
    @FocusState private var isSearchBarFocused: Bool;
    // 小圆点的智能底色
    private var dotBaseColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    
    
    // 💡 1. 核心新增：专门用来强行擦除布局缓存的屏幕指纹状态
    @State private var screenFingerprint: String = "init"
    
    var body: some View {
        GeometryReader { geometry in
            // 获取当前可用屏幕的宽高
            let pageWidth = geometry.size.width
            let pageHeight = geometry.size.height
            
            ZStack{
                SearchBarView(text: $searchText,isFocused: $isSearchBarFocused)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 20) // 避开状态栏
                    .zIndex(1)
                
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 0) {
                            ForEach(filteredPages,id: \.self){ page in
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnCount), spacing: 30) {
                                    ForEach(page.apps) { app in
                                        GridItemView(app: app)
                                    }
                                }
                                .padding(.horizontal, 60) // 两侧留白，防止图标贴边
                                .frame(width: pageWidth, height: pageHeight) // 💡 锁定单页宽高
                                .id(page.id)
                                .scaleEffect(viewModel.scale)
                                .opacity(1 - (viewModel.scale - 0.92) / 0.08)
                                .rotation3DEffect(.degrees((1 - viewModel.scale) * 8), axis: (x: 1,y: 0,z: 0), perspective: 0.8)
                            }
                        }.scrollTargetLayout()
                    }
                    .scrollPosition(id: $currentPageIndex)
                    .scrollTargetBehavior(.paging)
                    .scrollBounceBehavior(.always, axes: .horizontal)
                    .onTapGesture{
                        hideLaunchpad()
                    }
                    .focusable()
                    .focused($isBackgroundFocused)
                    .focusEffectDisabled(true)
            
                
                if filteredPages.count > 1 {
                    HStack(spacing: 12) {
                        ForEach(0..<filteredPages.count, id: \.self) { index in
                            Circle()
                            .fill(dotBaseColor.opacity(currentPageIndex == index ? 0.9 : 0.25))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPageIndex == index ? 1.2 : 1.0)
                                .onHover{ hovering in
                                    if hovering {
                                        NSCursor.pointingHand.push()
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentPageIndex = index
                                    }
                                }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 20) // 距离屏幕底部的安全边距
                    // 顺滑的小圆点过渡动画
                    .animation(.snappy(duration: 0.2), value: currentPageIndex)
                    .zIndex(1)
                }
            }
            // 💡 2. 【核心重磅修正】：把 screenFingerprint 绑定为整个网格容器的唯一 ID！
            // 只要指纹变了，SwiftUI 会物理清空上一屏的所有布局快照缓存，确保进场动画的第 0 毫秒尺寸绝对精准
            .id(viewModel.screenFingerprint)
        }
        // MARK: - 💡 【失去焦点自动隐藏】：监听系统窗口变为非活动状态的通知
        // 比如用户点击了桌面上别的软件窗口，或者点击了通知中心，Launchpad 会立刻自动收起
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            WindowManager.shared.hideLaunchpad()
        }
        // 当 Launchpad 被快捷键唤醒弹出时，强制把键盘焦点塞给大背景，确保方向键立刻可用
        .onAppear {
            isBackgroundFocused = true
            searchText = ""
            currentPageIndex = 0
        }
        .onChange(of: searchText){ oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if let current = currentPageIndex, current >= filteredPages.count {
                    currentPageIndex = 0
                }
            }
            
        }.accelerateKeyboard(
            maxPages: filteredPages.count,
            currentPageIndex: $currentPageIndex,
            searchText: $searchText,
            isSearchBarFocused: $isSearchBarFocused,  // 👈 直接传入
            isBackgroundFocused: $isBackgroundFocused // 👈 直接传入
        )
    }
    
    
    private func openApp(url:URL){
        NSWorkspace.shared.open(url)
    }
    
    
}

// MARK: - 辅助工具：数组切片扩展
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Array: @retroactive Identifiable where Element: Identifiable {
    public var id: Element.ID { self.first!.id }
}

    

