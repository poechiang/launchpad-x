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
    
    var body: some View {
    
            VStack(){
                Image(nsImage: app.icon).resizable()
                    .interpolation(.high)
                    .frame(width: 128, height: 128)
                    .shadow(radius: 6)
                Text(app.name)
                    .font(.system(size: 13,weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(isHovering ? nil : 1)
                    .multilineTextAlignment(.center)
                    .frame(width: 128)
                    .fixedSize(horizontal: false, vertical: true)
                
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
