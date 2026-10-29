//
//  GameView.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI

struct GameView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: GameViewModel
    @FocusState private var inputFocused: Bool

    init(difficulty: GameDifficulty, customRange: ClosedRange<Int>? = nil) {
        _viewModel = State(initialValue: GameViewModel(difficulty: difficulty, customRange: customRange))
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(viewModel.session.remainingRange.description)
                .font(.system(.title2, design: .monospaced, weight: .medium))

            if let result = viewModel.lastResult {
                Text(feedbackKey(for: result.feedback))
                    .font(.headline)
                    .foregroundStyle(feedbackColor(for: result.feedback))
            } else {
                Text(" ").font(.headline)
            }

            TextField("game.input.placeholder", text: $viewModel.input)
                .textFieldStyle(.roundedBorder)
                .font(.system(.title3, design: .monospaced))
                .multilineTextAlignment(.center)
                .frame(width: 160)
                .focused($inputFocused)
                .onSubmit { viewModel.submitGuess() }

            HStack(spacing: 8) {
                Button("game.guess") { viewModel.submitGuess() }
                    .adaptiveGlassButton(prominent: true)
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(viewModel.session.isFinished || viewModel.input.isEmpty)

                Button("game.restart") { viewModel.reset() }
                    .adaptiveGlassButton(prominent: false)
                    .keyboardShortcut("r", modifiers: .command)
            }
            .controlSize(.regular)

            if let best = viewModel.bestAttempts {
                Text("game.best \(best)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text(" ").font(.footnote)
            }
        }
        .padding(20)
        .frame(minWidth: 260, idealWidth: 280, minHeight: 220, idealHeight: 240)
        .onAppear { inputFocused = true }
        .onChange(of: appState.newGameTrigger) { _, _ in viewModel.reset() }
    }

    private func feedbackKey(for feedback: GuessResult.Feedback) -> LocalizedStringKey {
        switch feedback {
        case .tooLow:  return "game.tooLow"
        case .tooHigh: return "game.tooHigh"
        case .correct: return "game.correct"
        }
    }

    private func feedbackColor(for feedback: GuessResult.Feedback) -> Color {
        switch feedback {
        case .tooLow, .tooHigh: return .secondary
        case .correct: return .green
        }
    }
}
