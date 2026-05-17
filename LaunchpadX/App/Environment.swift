//
//  HideLaunchpadAction.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/13.
//

import SwiftUI

struct HideLaunchpadActionKey: EnvironmentKey {

    static let defaultValue: () -> Void = {

    }
}

extension EnvironmentValues {

    var hideLaunchpad: () -> Void {

        get {
            self[HideLaunchpadActionKey.self]
        }

        set {
            self[HideLaunchpadActionKey.self] = newValue
        }
    }
}
