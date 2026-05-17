//
//  LaunchpadBackgroundContainer.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//

import SwiftUI

struct ScaleContainer<Content: View>: View{
    
    let content:Content
    let scale: CGFloat
    
    var body: some View{
        content
            .scaleEffect(scale)
            .opacity(1 - (scale - 0.92) / 0.08)
            .rotation3DEffect(.degrees((1 - scale) * 8), axis: (x: 1,y: 0,z: 0), perspective: 0.8)
    }
    
    init(scale: CGFloat,@ViewBuilder content: ()->Content) {
        self.content = content()
        self.scale = scale
    }
}
