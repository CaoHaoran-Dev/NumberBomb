//
//  HelpView.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(icon: "info.circle", title: "help.section.overview") {
                        Text("help.overview.desc")
                    }
                    
                    Divider()
                    
                    section(icon: "gamecontroller", title: "help.section.rules") {
                        VStack(alignment: .leading, spacing: 8) {
                            bullet(text: "help.rules.point1")
                            bullet(text: "help.rules.point2")
                            bullet(text: "help.rules.point3")
                        }
                    }
                    
                    Divider()
                    
                    section(icon: "slider.horizontal.3", title: "help.section.difficulty") {
                        VStack(alignment: .leading, spacing: 8) {
                            bullet(text: "help.difficulty.easy")
                            bullet(text: "help.difficulty.medium")
                            bullet(text: "help.difficulty.hard")
                            bullet(text: "help.difficulty.custom")
                        }
                    }
                    
                    Divider()
                    
                    #if os(macOS)
                    section(icon: "keyboard", title: "help.section.shortcuts") {
                        VStack(alignment: .leading, spacing: 8) {
                            shortcutRow(keys: "⌘ R", desc: "help.shortcut.restart")
                            shortcutRow(keys: "⌘ D", desc: "help.shortcut.difficulty")
                            shortcutRow(keys: "⌘ ?", desc: "help.shortcut.help")
                            shortcutRow(keys: "Return", desc: "help.shortcut.guess")
                        }
                    }
                    Divider()
                    #endif
                    
                    section(icon: "person.crop.circle", title: "help.section.about") {
                        Text("help.about.desc")
                    }
                }
                .padding(20)
            }
            .navigationTitle("help.title")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline) // 强制标题居中缩小，原版默认是大标题（Large Title），显得头重脚轻
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") {
                        dismiss()
                    }
                    // 移除了 adaptiveGlassButton，让系统自动处理工具栏按钮的原生样式
                }
            }
        }
        #if os(macOS)
        .frame(width: 480, height: 520)
        #endif
    }

    // MARK: - 组件

    @ViewBuilder
    private func section<Content: View>(icon: String, title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.tint)
                    .font(.headline)
                Text(title)
                    .font(.headline)
            }
            content()
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func bullet(text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
            Text(text)
        }
    }

    private func shortcutRow(keys: String, desc: LocalizedStringKey) -> some View {
        HStack {
            Text(keys)
                .font(.system(.subheadline, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(4)
                .frame(width: 60, alignment: .leading)
            Text(desc)
        }
    }
}
