//
//  GlassModifier.swift
//  NumberBomb
//
//  Created by Haoran on 2026/10/29.
//

import SwiftUI

// 液态玻璃按钮扩展：iOS 26 / macOS 26 支持原生的 .glass 样式，低版本回退到原来的样式
extension View {
    @ViewBuilder
    func adaptiveGlassButton(prominent: Bool = false) -> some View {
        if #available(iOS 26, macOS 26, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }

    @ViewBuilder
    func adaptiveGlassBackground(cornerRadius: CGFloat = 8) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(Color.gray.opacity(0.1))
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        }
    }
}
