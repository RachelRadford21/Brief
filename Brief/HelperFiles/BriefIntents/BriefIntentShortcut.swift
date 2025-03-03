//
//  BriefIntentShortcut.swift
//  Brief
//
//  Created by Rachel Radford on 2/24/25.
//

import AppIntents

struct BriefIntentShortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: BriefIntent(),
                phrases: [
                    "Open my article in \(.applicationName)",
                    "Open article in \(.applicationName)",
                    "Can you open my article in \(.applicationName)"
                ],
                shortTitle: "Open Article",
                systemImageName: "briefcase.fill"
            ),
            AppShortcut(
                intent: BriefIntent(),
                phrases: [
                    "Open article about [article] in Brief",
                    "Find news about [article] in Brief",
                    "Show me the [article] article in Brief"
                ],
                shortTitle: "Open Article",
                systemImageName: "doc.text"
            )
        ]
    }
}
