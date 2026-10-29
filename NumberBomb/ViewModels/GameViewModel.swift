//
//  GameViewModel.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import Foundation
import Observation

@Observable
final class GameViewModel {
    private(set) var session: GameSession
    private(set) var lastResult: GuessResult?
    private(set) var bestAttempts: Int?
    var input: String = ""

    private let recordStore: BestRecordStore
    private let customRange: ClosedRange<Int>?

    init(difficulty: GameDifficulty,
         customRange: ClosedRange<Int>? = nil,
         recordStore: BestRecordStore = UserDefaultsRecordStore()) {
        self.recordStore = recordStore
        self.customRange = customRange
        self.session = GameSession(difficulty: difficulty, range: customRange)
        let key = recordStore.key(for: difficulty, customRange: customRange)
        self.bestAttempts = recordStore.bestAttempts(for: key)
    }

    func submitGuess() {
        guard let value = Int(input), !session.isFinished else { return }
        let result = session.guess(value)
        lastResult = result
        input = ""
        if result.feedback == .correct { updateBest() }
    }

    func reset() {
        session = GameSession(difficulty: session.difficulty, range: customRange)
        lastResult = nil
        input = ""
    }

    private func updateBest() {
        let attempts = session.attempts
        if bestAttempts.map({ attempts < $0 }) ?? true {
            bestAttempts = attempts
            let key = recordStore.key(for: session.difficulty, customRange: customRange)
            recordStore.setBestAttempts(attempts, for: key)
        }
    }
}
