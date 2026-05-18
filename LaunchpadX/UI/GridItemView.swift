//
//  ContentView.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import SwiftUI

struct GridItemView: View {
    let app: LaunchpadApp
    @State private var isHovering = false
    
    @Environment(\.hideLaunchpad)
    private var hideLaunchpad
    
    // 💡 核心新增：捕获当前的系统主题（.light 或 .dark）
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
    
            VStack(){
                Image(nsImage: app.icon).resizable()
                    .interpolation(.high)
                    .frame(width: 128, height: 128)
                    .shadow(radius: 6)
                Text(app.name)
                    .font(.system(size: 13,weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 128)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .opacity(0) // 完全隐形，仅用于占位
                    // 💡 核心魔法：使用 overlay 挂载真正要显示的文本
                    .overlay(
                        // 根据悬停状态决定是单行截断还是全文本
                        Text(app.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
//                            .shadow(color: colorScheme == .dark ? .black.withAlphaComponent(0.5) : .clear, radius: 2, x: 0, y: 1)
                            // 💡 悬停时 lineLimit 设为 nil（不限行数），平时设为 1 行并缩略
                            .lineLimit(isHovering ? nil : 1)
                            .multilineTextAlignment(.center) // 文字居中对齐
                            .fixedSize(horizontal: false, vertical: isHovering) // 💡 允许悬停时纵向自然向下延展
                            .frame(width: 110) // 限制文字的最大排版宽度，防止向两边爆开
                            
                            // 💡 细节优化：悬停全显示时，给文字背后加一个微微带磨砂或阴影的底色，防止多行文本挡住下方其他图标的字时看不清
                            .padding(.horizontal, isHovering ? 6 : 0)
                            .padding(.vertical, isHovering ? 4 : 0)
                            .cornerRadius(6)
                            
                            // 💡 强制把对齐锚点锁在顶部边缘，让多行字绝不往上顶，而是完全向下“垂挂”
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    )
                
            }
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .frame(width: 140, height: 160, alignment: .center)
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovering = hovering
            }
            .onTapGesture{
                openApp(url: app.url)
                hideLaunchpad()
            }
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                }
                else{
                    NSCursor.pop()
                }
            }
                    
    }
        
            
    
    
    
    private func openApp(url:URL){
        print("点击app")
        NSWorkspace.shared.open(url)
    }
}
