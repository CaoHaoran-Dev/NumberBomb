//
//  NumberBombApp.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI
import Observation
#if os(macOS)
internal import AppKit
#endif

@Observable
final class AppState {
    var isHelpPresented = false
    var isDifficultyPickerPresented = false
    var selectedDifficulty: GameDifficulty = .medium
    var customRange: ClosedRange<Int> = 1...100
    var newGameTrigger = 0
}

@main
struct NumberBombApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            content
                .environment(appState)
                .sheet(isPresented: $appState.isHelpPresented) {
                    HelpView()
                }
                .sheet(isPresented: $appState.isDifficultyPickerPresented) {
                    DifficultySelectionView()
                        .environment(appState)
                }
                #if os(macOS)
                .onAppear {
                    // 强制应用激活，并把窗口带到最前
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                        if let window = NSApp.windows.first {
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 280, height: 240)
        .windowResizability(.contentSize)
        .commands { MacCommands(appState: appState) }
        #endif
    }

    @ViewBuilder
    private var content: some View {
        #if os(iOS)
        NavigationStack {
            GameView(
                difficulty: appState.selectedDifficulty,
                customRange: appState.customRange
            )
            .id("\(appState.selectedDifficulty.rawValue)-\(appState.customRange)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        // 帮助按钮
                        Button {
                            appState.isHelpPresented = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        
                        // 难度切换按钮
                        Button {
                            appState.isDifficultyPickerPresented = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
        }
        #else
        GameView(
            difficulty: appState.selectedDifficulty,
            customRange: appState.customRange
        )
        .id("\(appState.selectedDifficulty.rawValue)-\(appState.customRange)")
        #endif
    }
}
