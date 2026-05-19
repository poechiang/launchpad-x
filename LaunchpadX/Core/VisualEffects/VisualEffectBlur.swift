//
//  VisualEffectBlur.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/10.
//
import SwiftUI
import AppKit

struct VisualEffectBlur: NSViewRepresentable {
    var state: NSVisualEffectView.State = .inactive

    func makeNSView(context: Context) -> NSVisualEffectView {

        let view = NSVisualEffectView()

        view.material = .underWindowBackground
        view.blendingMode = .withinWindow
        view.state = state
        

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.state = state
    }
}
