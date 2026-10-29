//
//  GameEngine.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import Foundation

enum GameDifficulty: String, CaseIterable, Identifiable {
    case easy, medium, hard, custom

    var id: String { rawValue }

    var range: ClosedRange<Int>? {
        switch self {
        case .easy:   return 1...50
        case .medium: return 1...100
        case .hard:   return 1...500
        case .custom: return nil
        }
    }

    var titleKey: String { "difficulty.\(rawValue)" }
}

struct GuessResult: Equatable {
    enum Feedback: Equatable {
        case tooLow, tooHigh, correct
    }
    let value: Int
    let feedback: Feedback
    let remainingRange: ClosedRange<Int>
}

struct GameSession {
    let difficulty: GameDifficulty
    let fullRange: ClosedRange<Int>
    private(set) var target: Int
    private(set) var remainingRange: ClosedRange<Int>
    private(set) var attempts = 0
    private(set) var isFinished = false

    init(difficulty: GameDifficulty, range: ClosedRange<Int>? = nil, target: Int? = nil) {
        self.difficulty = difficulty
        let resolved = range ?? difficulty.range ?? 1...100
        self.fullRange = resolved
        self.target = target ?? resolved.randomElement()!
        self.remainingRange = resolved
    }

    mutating func guess(_ value: Int) -> GuessResult {
        attempts += 1
        let feedback: GuessResult.Feedback
        switch value {
        case ..<target:
            feedback = .tooLow
            remainingRange = max(remainingRange.lowerBound, value + 1)...remainingRange.upperBound
        case (target + 1)...:
            feedback = .tooHigh
            remainingRange = remainingRange.lowerBound...min(remainingRange.upperBound, value - 1)
        default:
            feedback = .correct
            remainingRange = value...value
            isFinished = true
        }
        return GuessResult(value: value, feedback: feedback, remainingRange: remainingRange)
    }
}
