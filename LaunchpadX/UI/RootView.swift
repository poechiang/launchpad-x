// 背景根视图
//  RootView.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var vm: LaunchpadViewModel
    
    var body: some View {
        
        ScaleContainer(scale:vm.scale){
            GridView(viewModel: vm)
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .environment(\.hideLaunchpad,{
            print("hide launchpad")
            WindowManager.shared.hideLaunchpad()
        })
        .animation(
            vm.phase == .hidden
            ? .easeOut(duration: 0.25)
            : .easeIn(duration: 0.1),
            value: vm.scale

        ).background{
            VisualEffectBlur(state: vm.scale < 0.95 ? .active : .inactive)
        }        
    }
    


    
}

#Preview{
    RootView(vm:LaunchpadViewModel())
}

