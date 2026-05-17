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
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14))
                
                TextField("", text: $text, prompt: Text("搜索").foregroundColor(.white.opacity(0.4)))
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .regular))
                    .focused($isFocused)
                
                // 如果有内容，显示清除按钮
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(width: 260, height: 32)
            // 贴合系统 Launchpad 的搜索框半透明深色背景
            .background(Color.white.opacity(0.12))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            Spacer()
        }
        .onAppear {
            // 💡 体验升级：快捷键唤起此界面时，搜索框自动获取焦点，用户直接打字即可进行筛选
            isFocused = true
        }
    }
}
