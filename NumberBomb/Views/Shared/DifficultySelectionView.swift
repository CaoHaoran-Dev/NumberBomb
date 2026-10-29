//
//  DifficultySelectionView.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI

struct DifficultySelectionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DifficultyViewModel()

    @State private var customLower = "1"
    @State private var customUpper = "100"

    var body: some View {
        #if os(iOS)
        iOSLayout
        #else
        macOSLayout
        #endif
    }

    // MARK: - iOS 原生布局
    private var iOSLayout: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(GameDifficulty.allCases.filter { $0 != .custom }) { difficulty in
                        Button {
                            appState.selectedDifficulty = difficulty
                            dismiss()
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(difficulty.titleKey))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let best = viewModel.best(for: difficulty, customRange: nil) {
                                    Text("game.best \(best)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                // 用系统自带的打钩样式
                                if difficulty == appState.selectedDifficulty {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }

                Section("difficulty.custom") {
                    HStack {
                        Text("difficulty.custom.lower")
                        Spacer()
                        TextField("1", text: $customLower)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("difficulty.custom.upper")
                        Spacer()
                        TextField("100", text: $customUpper)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let range = parsedRange, let best = viewModel.best(for: .custom, customRange: range) {
                        Text("game.best \(best)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    if parsedRange == nil {
                        Text("difficulty.custom.invalid")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    
                    Button("common.apply") {
                        applyCustom()
                    }
                    .disabled(parsedRange == nil)
                    // iOS 会默认把它居中对齐并应用原生的高亮颜色
                }
            }
            .navigationTitle("difficulty.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
                }
            }
            .onAppear { setupInitialValues() }
        }
    }

    // MARK: - macOS 布局
    private var macOSLayout: some View {
        VStack(spacing: 20) {
            Text("difficulty.title")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            VStack(spacing: 0) {
                ForEach(GameDifficulty.allCases.filter { $0 != .custom }) { difficulty in
                    Button {
                        appState.selectedDifficulty = difficulty
                        dismiss()
                    } label: {
                        HStack {
                            Text(LocalizedStringKey(difficulty.titleKey))
                                .foregroundStyle(.primary)
                                .font(.system(size: 13))
                            Spacer()
                            if let best = viewModel.best(for: difficulty, customRange: nil) {
                                Text("game.best \(best)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            if difficulty == appState.selectedDifficulty {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if difficulty != GameDifficulty.allCases.filter({ $0 != .custom }).last {
                        Divider()
                    }
                }
            }
            .adaptiveGlassBackground(cornerRadius: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("difficulty.custom")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    TextField("difficulty.custom.lower", text: $customLower)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .multilineTextAlignment(.center)
                    
                    Text("–")
                        .foregroundStyle(.secondary)
                    
                    TextField("difficulty.custom.upper", text: $customUpper)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .multilineTextAlignment(.center)

                    Button("common.apply") {
                        applyCustom()
                    }
                    .adaptiveGlassButton(prominent: false)
                    .disabled(parsedRange == nil)
                    .controlSize(.regular)
                }

                if let range = parsedRange, let best = viewModel.best(for: .custom, customRange: range) {
                    Text("game.best \(best)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if parsedRange == nil {
                    Text("difficulty.custom.invalid")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack {
                Spacer()
                Button("common.close") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                    .controlSize(.large)
            }
        }
        .padding(24)
        .frame(width: 400, height: 360)
    }

    // MARK: - 逻辑
    private var parsedRange: ClosedRange<Int>? {
        guard let lo = Int(customLower), let hi = Int(customUpper), lo < hi else { return nil }
        return lo...hi
    }

    private func applyCustom() {
        guard let range = parsedRange else { return }
        appState.customRange = range
        appState.selectedDifficulty = .custom
        dismiss()
    }

    private func setupInitialValues() {
        customLower = "\(appState.customRange.lowerBound)"
        customUpper = "\(appState.customRange.upperBound)"
    }
}
