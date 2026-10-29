//
//  DifficultyViewModel.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import Foundation
import Observation

@Observable
final class DifficultyViewModel {
    private let recordStore: BestRecordStore

    init(recordStore: BestRecordStore = UserDefaultsRecordStore()) {
        self.recordStore = recordStore
    }

    func key(for difficulty: GameDifficulty) -> String {
        recordStore.key(for: difficulty, customRange: nil)
    }

    func best(for difficulty: GameDifficulty, customRange: ClosedRange<Int>? = nil) -> Int? {
        let key = recordStore.key(for: difficulty, customRange: customRange)
        return recordStore.bestAttempts(for: key)
    }
}
