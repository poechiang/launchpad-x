//
//  SearchBarView.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/18.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool // 自动聚焦状态
    @Environment(\.colorScheme) var colorScheme
    
    private var iconColor:Color{
        colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5)
    }
    private var plhColor:Color{
        colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.3)
    }
    
    private var clearColor:Color{
        colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.4)
    }
    
    private var background: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06)
    }
    
    private var overlayStroke: Color {
        colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.08)
    }
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(iconColor)
                    .font(.system(size: 14))
                    .allowsHitTesting(true)
                
                TextField("",
                  text: $text,
                  prompt: Text("App名称、首字母、拼音全拼或简拼").foregroundColor(plhColor)
                )
                    .textFieldStyle(.plain)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .regular))
                    .focused($isFocused)
                    .onCommand( #selector(NSResponder.cancelOperation(_:)), perform:{
                        // 1. 先让输入框失去焦点（Blur）
                        isFocused = false
                        // 2. 触发全局隐藏（调用你的窗口隐藏方法）
                        DispatchQueue.main.async {
                            WindowManager.shared.hideLaunchpad()
                        }
                    
                    })
                // 如果有内容，显示清除按钮
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(clearColor)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        }
                        else{
                            NSCursor.pop()
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 12)
            .frame(width: 360, height: 32)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .background(background)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(overlayStroke, lineWidth: 1)
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.iBeam.push()
                }
                else{
                    NSCursor.pop()
                }
            }
            .onTapGesture {
                // 点击搜索栏内其他地方时，顺便帮输入框聚焦，提升体验
                isFocused = true
            }
            
            Spacer()
        }
        .onAppear {
            // 💡 体验升级：快捷键唤起此界面时，搜索框自动获取焦点，用户直接打字即可进行筛选
            isFocused = false
        }
    }
}
