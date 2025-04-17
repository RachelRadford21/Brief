//
//  IntentShortcut.swift
//  Brief
//
//  Created by Rachel Radford on 2/24/25.
//

import AppIntents

struct IntentShortcut: AppShortcutsProvider {
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
                    "Open article about [article] in Brief \(.applicationName)",
                    "Find news about [article] in Brief \(.applicationName)",
                    "Show me the [article] article in Brief \(.applicationName)"
                ],
                shortTitle: "Open Article",
                systemImageName: "doc.text"
            ),
            AppShortcut(
                       intent: NoteIntent(),
                       phrases: [
                           "Open note [note] in Brief \(.applicationName)",
                           "Show me note [note] in Brief \(.applicationName)",
                           "Read my note [note] in Brief \(.applicationName)"
                       ],
                       shortTitle: "Open Note",
                       systemImageName: "note.text"
                   )
        ]
    }
}
