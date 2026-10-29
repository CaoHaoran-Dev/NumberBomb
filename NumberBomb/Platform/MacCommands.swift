//
//  MacCommands.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI

struct MacCommands: Commands {
    let appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .help) {
            Button("menu.help") { appState.isHelpPresented = true }
                .keyboardShortcut("?", modifiers: .command)
        }
        CommandGroup(after: .newItem) {
            Button("menu.newGame") { appState.newGameTrigger += 1 }
                .keyboardShortcut("r", modifiers: .command)
            Button("menu.changeDifficulty") { appState.isDifficultyPickerPresented = true }
                .keyboardShortcut("d", modifiers: .command)
        }
    }
}
