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
    
    var body: some View {
        GeometryReader { geometry in
            // 获取当前可用屏幕的宽高
            let pageWidth = geometry.size.width
            let pageHeight = geometry.size.height
            ZStack(){
                
                SearchBarView(text: $searchText)
                    .frame(height: 80, alignment: .top)
                    .padding(.top, 20) // 避开状态栏
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 0) {
                        ForEach(filteredPages,id: \.self){ page in
                            // 【单页容器】：尺寸必须精准等于可用屏幕大小
                            VStack {
                                Spacer(minLength: 40) // 顶部留出菜单栏空间（或安全距离）
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnCount), spacing: 30) {
                                    ForEach(page.apps) { app in
                                        GridItemView(app: app)
                                    }
                                }
                                .padding(.horizontal, 60) // 两侧留白，防止图标贴边
                                
                                Spacer()
                            }
                            .frame(width: pageWidth, height: pageHeight) // 💡 锁定单页宽高
                            .id(page.id)
                        }
                    }
                }
                .scrollPosition(id: $currentPageIndex)
                .scrollTargetBehavior(.paging)
                .scrollBounceBehavior(.always, axes: .horizontal)
                .onTapGesture{
                    hideLaunchpad()
                }
                
                if filteredPages.count > 1 {
                    HStack(spacing: 12) {
                        ForEach(0..<filteredPages.count, id: \.self) { index in
                            Circle()
                            // 如果是当前页，变亮变大，否则变暗变小
                                .fill(Color.white.opacity(currentPageIndex == index ? 0.9 : 0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPageIndex == index ? 1.2 : 1.0)
                            // 添加点击圆点直接跳页的功能（如原生系统一致）
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentPageIndex = index
                                    }
                                }
                        }
                    }
                    .frame(alignment: .bottom)
                    .padding(.bottom, 20) // 距离屏幕底部的安全边距
                    // 顺滑的小圆点过渡动画
                    .animation(.snappy(duration: 0.2), value: currentPageIndex)
                }
            }
        }
        .onChange(of: searchText){ oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if let current = currentPageIndex, current >= filteredPages.count {
                    currentPageIndex = 0
                }
            }
            
        }
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

    

