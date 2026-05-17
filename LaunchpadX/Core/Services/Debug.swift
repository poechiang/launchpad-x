//
//  Debug.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/14.
//

import Foundation
final class Debugger {

    static func log(_ msg:Any)  {
        
        print("\(Date().ISO8601Format()) LaunchpadX \(msg)")
    }
}
