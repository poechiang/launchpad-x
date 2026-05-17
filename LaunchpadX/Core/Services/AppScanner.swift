//
//  AppScanner.swift
//  LaunchpadX
//
//  Created by Jeffrey Chiang on 2026/5/11.
//
import Foundation
import AppKit

final class AppScanner {

    static func loadApplications() -> [LaunchpadApp] {

        let paths = [
            "/Applications",
            "/System/Applications",
            "\(NSHomeDirectory())/Applications"
        ]
        
        let contents: [URL] = paths.flatMap { path in

            let url = URL(fileURLWithPath: path)

            return (try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil
            )) ?? []
        }
        
        let sorted = contents.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare(
                $1.lastPathComponent
            ) == .orderedAscending
        }

        return sorted.compactMap { appURL in

            guard appURL.pathExtension == "app" else {
                return nil
            }

            let bundle = Bundle(url: appURL)

            let name =
                bundle?.object(
                    forInfoDictionaryKey: "CFBundleName"
                ) as? String
                ?? appURL.deletingPathExtension().lastPathComponent

            let bundleId =
                bundle?.bundleIdentifier
                ?? "unknown.\(name)"

            let icon =
                NSWorkspace.shared.icon(
                    forFile: appURL.path
                )

            let isSystem =
                appURL.path.contains("/System/")
                || appURL.path.contains("/System Applications/")

            return LaunchpadApp(
                bundleId: bundleId,
                isSystemApp: isSystem,
                name: name,
                icon: icon,
                iconCacheKey: bundleId,
                url: appURL
            )
        }
    }
}
