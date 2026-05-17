//
//  LaunchpadWindow.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//
import Cocoa
import SwiftUI

final class LaunchpadWindow: NSWindow{
    override var canBecomeKey: Bool {true}
    override var canBecomeMain: Bool{true}
    let viewModel = LaunchpadViewModel()
    
    init(){
        
        super.init(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless],
            backing: .buffered, defer: false
        )
        
        configureWindow()
        
        contentView = NSHostingView(rootView: RootView(vm:viewModel))
        
    }
    
    private func configureWindow(){
        //完全透明标题栏
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        // 背景透明
        backgroundColor = .clear;
        // 不透明关闭
        isOpaque = true
        // 不允许拖动
        isMovable = false
        isReleasedWhenClosed = false
        
        collectionBehavior = [
            .fullScreenAuxiliary, // 不进系统fullscreen
            .canJoinAllSpaces, // 跨桌面显示
            .stationary, // 不随Space滚动
            .ignoresCycle // 不参与 Cmd+Tab
                
        ]
        
         // 覆盖 Dock / MenuBar
        level =  .statusBar
        
    
         // 接收键盘事件
        acceptsMouseMovedEvents = true
        
        makeFirstResponder(self)
        alphaValue = 0
    }
    
    override func mouseDown(with event: NSEvent) {
        WindowManager.shared.hideLaunchpad()
    }
    
    override func keyDown(with event: NSEvent) {
        if( event.keyCode == 53){ // ESC 退出
            WindowManager.shared.hideLaunchpad()
        }else{
            super.keyDown(with: event)
        }
    }
}
