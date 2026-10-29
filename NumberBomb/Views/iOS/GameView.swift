//
//  GameView.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI

struct GameView: View {
    @State private var viewModel: GameViewModel
    @State private var feedbackTrigger = false

    init(difficulty: GameDifficulty, customRange: ClosedRange<Int>? = nil) {
        _viewModel = State(initialValue: GameViewModel(difficulty: difficulty, customRange: customRange))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.session.remainingRange.description)
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .contentTransition(.numericText())

            if let result = viewModel.lastResult {
                Text(feedbackKey(for: result.feedback))
                    .font(.headline)
                    .foregroundStyle(feedbackColor(for: result.feedback))
                    .transition(.opacity.combined(with: .scale))
            }

            TextField("game.input.placeholder", text: $viewModel.input)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .font(.system(.title3, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            HStack(spacing: 12) {
                Button("game.guess") {
                    viewModel.submitGuess()
                    feedbackTrigger.toggle()
                }
                .adaptiveGlassButton(prominent: true)
                .controlSize(.large)
                .disabled(viewModel.session.isFinished || viewModel.input.isEmpty)

                Button("game.restart") {
                    viewModel.reset()
                }
                .adaptiveGlassButton(prominent: false)
                .controlSize(.large)
            }

            if let best = viewModel.bestAttempts {
                Text("game.best \(best)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle(LocalizedStringKey(viewModel.session.difficulty.titleKey))
        .sensoryFeedback(.impact(weight: .light), trigger: feedbackTrigger) { _, _ in
            viewModel.lastResult != nil && !viewModel.session.isFinished
        }
        .sensoryFeedback(.success, trigger: viewModel.session.isFinished) { _, finished in
            finished
        }
        .animation(.default, value: viewModel.lastResult)
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
