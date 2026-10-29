//
//  BestRecordStore.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import Foundation

protocol BestRecordStore {
    func bestAttempts(for key: String) -> Int?
    func setBestAttempts(_ attempts: Int, for key: String)
}

extension BestRecordStore {
    func key(for difficulty: GameDifficulty, customRange: ClosedRange<Int>? = nil) -> String {
        if difficulty == .custom, let range = customRange {
            return "best.custom.\(range.lowerBound)-\(range.upperBound)"
        }
        return "best.\(difficulty.rawValue)"
    }
}

final class UserDefaultsRecordStore: BestRecordStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func bestAttempts(for key: String) -> Int? {
        guard defaults.object(forKey: key) != nil else { return nil }
        return defaults.integer(forKey: key)
    }

    func setBestAttempts(_ attempts: Int, for key: String) {
        defaults.set(attempts, forKey: key)
    }
}
