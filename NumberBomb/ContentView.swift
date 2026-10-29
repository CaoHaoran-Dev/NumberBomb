//
//  ContentView.swift
//  NumberBomb
//
//  Created by Haoran on 2026/3/1.
//

import SwiftUI

// MARK: - 语言枚举
enum Language: String, CaseIterable {
    case simplifiedChinese = "简体中文"
    case englishUS = "English (US)"
}

// MARK: - 主视图
struct ContentView: View {
    // 游戏状态
    @State private var 炸弹数字 = 0
    @State private var 用户输入 = ""
    @State private var 提示信息 = ""
    @State private var 猜测次数 = 0
    @State private var 游戏结束 = false
    
    // 每个难度的最佳成绩
    @AppStorage("最佳成绩简单") private var 最佳成绩简单 = Int.max
    @AppStorage("最佳成绩中等") private var 最佳成绩中等 = Int.max
    @AppStorage("最佳成绩困难") private var 最佳成绩困难 = Int.max
    @AppStorage("最佳成绩自定义") private var 最佳成绩自定义 = Int.max
    
    // 当前选中难度索引
    @AppStorage("选中难度索引") private var 选中难度 = 1 // 默认中等
    @State private var 最大值 = 100
    
    // 自定义范围
    @AppStorage("自定义最小值") private var 自定义最小值 = 1
    @AppStorage("自定义最大值") private var 自定义最大值 = 200
    
    // 语言设置
    @AppStorage("语言") private var 语言 = Language.simplifiedChinese.rawValue
    private var 当前语言: Language {
        Language(rawValue: 语言) ?? .simplifiedChinese
    }
    
    // 本地化的难度选项
    var 本地化难度选项: [String] {
        switch 当前语言 {
        case .simplifiedChinese:
            return ["简单 (1~50)", "中等 (1~100)", "困难 (1~500)", "自定义"]
        case .englishUS:
            return ["Easy (1~50)", "Medium (1~100)", "Hard (1~500)", "Custom"]
        }
    }
    
    // 当前难度对应的最佳成绩
    var 当前最佳成绩: Int {
        switch 选中难度 {
        case 0: return 最佳成绩简单
        case 1: return 最佳成绩中等
        case 2: return 最佳成绩困难
        case 3: return 最佳成绩自定义
        default: return Int.max
        }
    }
    
    // 控制 sheet 显示
    @State private var 显示设置 = false
    @State private var 显示帮助 = false
    
    // 动画
    @State private var 动画幅度: CGFloat = 1.0
    
    var body: some View {
        #if os(iOS)
        // iOS 风格
        NavigationView {
            VStack(spacing: 20) {
                游戏内容
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(文本("💣 数字炸弹 💣"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        显示帮助 = true
                    }) {
                        Image(systemName: "questionmark.circle")
                    }
                    
                    Button(action: {
                        显示设置 = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $显示设置) {
                设置视图(自定义最小值: $自定义最小值, 自定义最大值: $自定义最大值, 语言: $语言, 当前语言: 当前语言)
                    .onDisappear {
                        // sheet 消失后重置状态（确保下次可以再次打开）
                        DispatchQueue.main.async {
                            显示设置 = false
                        }
                    }
            }
            .sheet(isPresented: $显示帮助) {
                帮助视图(当前语言: 当前语言)
                    .onDisappear {
                        DispatchQueue.main.async {
                            显示帮助 = false
                        }
                    }
            }
            .onAppear {
                重新开始()
            }
        }
        .id(语言) // 语言变化时强制刷新
        #else
        // macOS 风格
        VStack(spacing: 20) {
            Text(文本("💣 数字炸弹 💣"))
                .font(.largeTitle)
                .foregroundColor(.red)
                .scaleEffect(动画幅度)
                .animation(.easeInOut(duration: 0.3), value: 动画幅度)
            
            游戏内容
            
            Spacer()
            
            // 底部按钮
            HStack {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { 显示帮助 = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .help(文本("帮助"))
                    
                    Button(action: { 显示设置 = true }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .help(文本("设置"))
                }
                Spacer()
            }
            .padding(.bottom)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .id(语言)
        .sheet(isPresented: $显示设置) {
            设置视图(自定义最小值: $自定义最小值, 自定义最大值: $自定义最大值, 语言: $语言, 当前语言: 当前语言)
                .onDisappear {
                    DispatchQueue.main.async {
                        显示设置 = false
                    }
                }
        }
        .sheet(isPresented: $显示帮助) {
            帮助视图(当前语言: 当前语言)
                .onDisappear {
                    DispatchQueue.main.async {
                        显示帮助 = false
                    }
                }
        }
        .onAppear {
            重新开始()
        }
        #endif
    }
    
    // 游戏内容（两个平台共享）
    var 游戏内容: some View {
        Group {
            // 难度选择器
            Picker(文本("难度"), selection: $选中难度) {
                ForEach(0..<本地化难度选项.count, id: \.self) { index in
                    Text(本地化难度选项[index])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: 选中难度) { _ in
                重新开始()
            }
            
            // 当前难度范围和最佳成绩
            HStack {
                Text("\(文本("范围")): 1~\(最大值)")
                Spacer()
                if 当前最佳成绩 != Int.max {
                    Text("\(文本("最佳")): \(当前最佳成绩) \(文本("次"))")
                } else {
                    Text(文本("最佳: 暂无"))
                }
            }
            .font(.headline)
            .padding(.horizontal)
            
            // 提示信息
            Text(提示信息)
                .font(.title2)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            // 输入框
            TextField(文本("在这里输入数字"), text: $用户输入)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .disabled(游戏结束)
            
            // 按钮组
            HStack {
                Spacer()
                Button(文本("猜！")) {
                    处理猜测()
                }
                .font(.system(size: 28))
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .disabled(游戏结束)
                
                Spacer().frame(width: 20)
                
                Button(文本("新游戏")) {
                    重新开始()
                }
                .font(.system(size: 28))
                .buttonStyle(.bordered)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Spacer()
            }
            
            // 游戏结束信息
            if 游戏结束 {
                Text(String(format: 文本("你用了 %d 次猜中！"), 猜测次数))
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // 重新开始游戏
    func 重新开始() {
        switch 选中难度 {
        case 0: 最大值 = 50
        case 1: 最大值 = 100
        case 2: 最大值 = 500
        case 3: 最大值 = 自定义最大值
        default: 最大值 = 100
        }
        炸弹数字 = Int.random(in: 1...最大值)
        提示信息 = String(format: 文本("猜一个 1~%d 的数字"), 最大值)
        用户输入 = ""
        游戏结束 = false
        猜测次数 = 0
    }
    
    // 处理猜测
    func 处理猜测() {
        guard let 猜的数字 = Int(用户输入) else {
            提示信息 = 文本("请输入一个有效的数字！")
            return
        }
        
        猜测次数 += 1
        
        if 猜的数字 == 炸弹数字 {
            提示信息 = 文本("🎉 恭喜！你猜中了！")
            游戏结束 = true
            触发动画()
            更新最佳成绩()
        } else if 猜的数字 < 炸弹数字 {
            提示信息 = 文本("⬆️ 猜小了，再大一点")
        } else {
            提示信息 = 文本("⬇️ 猜大了，再小一点")
        }
        
        用户输入 = ""
    }
    
    // 触发动画
    func 触发动画() {
        动画幅度 = 1.5
        withAnimation(.easeInOut(duration: 0.3)) {
            动画幅度 = 1.0
        }
    }
    
    // 更新最佳成绩
    func 更新最佳成绩() {
        let 新成绩 = 猜测次数
        switch 选中难度 {
        case 0:
            if 新成绩 < 最佳成绩简单 { 最佳成绩简单 = 新成绩 }
        case 1:
            if 新成绩 < 最佳成绩中等 { 最佳成绩中等 = 新成绩 }
        case 2:
            if 新成绩 < 最佳成绩困难 { 最佳成绩困难 = 新成绩 }
        case 3:
            if 新成绩 < 最佳成绩自定义 { 最佳成绩自定义 = 新成绩 }
        default: break
        }
    }
    
    // 根据当前语言返回文本
    func 文本(_ key: String) -> String {
        switch 当前语言 {
        case .simplifiedChinese:
            return chineseText[key] ?? key
        case .englishUS:
            return englishText[key] ?? key
        }
    }
}

// MARK: - 设置视图
struct 设置视图: View {
    @Binding var 自定义最小值: Int
    @Binding var 自定义最大值: Int
    @Binding var 语言: String
    let 当前语言: Language
    
    @Environment(\.dismiss) var 关闭
    @State private var 显示语言选择 = false  // iOS 专用
    
    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ " + 文本("设置"))
                .font(.largeTitle)
                .padding(.top)
            
            // 语言选择（平台区分）
            #if os(macOS)
            HStack {
                Text(文本("语言") + ":")
                Spacer()
                Picker("", selection: $语言) {
                    ForEach(Language.allCases, id: \.self) { lang in
                        Text(lang.rawValue).tag(lang.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }
            .padding(.horizontal)
            #else
            HStack {
                Text(文本("语言") + ":")
                Spacer()
                Button(action: { 显示语言选择 = true }) {
                    Text(语言)
                        .foregroundColor(.primary)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .sheet(isPresented: $显示语言选择) {
                语言选择视图(语言: $语言, 当前语言: 当前语言)
                    .onDisappear {
                        DispatchQueue.main.async {
                            显示语言选择 = false
                        }
                    }
            }
            #endif
            
            Divider()
            
            // 自定义范围设置
            Text(文本("自定义难度范围"))
                .font(.title2)
            
            HStack {
                Text(文本("最小值") + ":")
                TextField("", value: $自定义最小值, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                
                Text(文本("最大值") + ":")
                TextField("", value: $自定义最大值, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(文本("完成")) {
                关闭()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .frame(width: 400, height: 300)
        .padding()
    }
    
    private func 文本(_ key: String) -> String {
        switch 当前语言 {
        case .simplifiedChinese:
            return chineseText[key] ?? key
        case .englishUS:
            return englishText[key] ?? key
        }
    }
}

// MARK: - 语言选择视图（仅 iOS 使用）
struct 语言选择视图: View {
    @Binding var 语言: String
    let 当前语言: Language
    @Environment(\.dismiss) var 关闭
    
    var body: some View {
        NavigationView {
            List(Language.allCases, id: \.self) { 语言选项 in
                Button(action: {
                    语言 = 语言选项.rawValue
                    关闭()
                }) {
                    HStack {
                        Text(语言选项.rawValue)
                        Spacer()
                        if 语言选项.rawValue == 语言 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle(文本("选择语言"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(文本("取消")) {
                        关闭()
                    }
                }
            }
        }
    }
    
    private func 文本(_ key: String) -> String {
        switch 当前语言 {
        case .simplifiedChinese:
            return chineseText[key] ?? key
        case .englishUS:
            return englishText[key] ?? key
        }
    }
}

// MARK: - 帮助视图
struct 帮助视图: View {
    let 当前语言: Language
    @Environment(\.dismiss) var 关闭
    
    var body: some View {
        VStack(spacing: 20) {
            Text(文本("📖 帮助"))
                .font(.largeTitle)
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(文本("1. 系统随机生成一个1~范围内的数字作为“炸弹”。"))
                    Text(文本("2. 你在输入框中输入猜测的数字，然后点击“猜！”。"))
                    Text(文本("3. 系统会提示“猜大了”或“猜小了”，直到猜中为止。"))
                    Text(文本("4. 猜中后游戏结束，并记录本次猜测次数。"))
                    Text(文本("5. 每个难度有独立的最佳成绩记录。"))
                    
                    Divider()
                    
                    Text(文本("操作说明："))
                        .font(.title2)
                        .bold()
                    Text(文本("• 点击难度选择器可切换难度。"))
                    Text(文本("• 点击“新游戏”可重置当前难度的游戏。"))
                    Text(文本("• 点击右上角齿轮图标打开设置，可调整自定义范围和语言。"))
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(文本("关闭")) {
                关闭()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .frame(minWidth: 300, minHeight: 400)
        .padding()
    }
    
    private func 文本(_ key: String) -> String {
        switch 当前语言 {
        case .simplifiedChinese:
            return chineseText[key] ?? key
        case .englishUS:
            return englishText[key] ?? key
        }
    }
}

// MARK: - 多语言文本字典
let chineseText: [String: String] = [
    "💣 数字炸弹 💣": "💣 数字炸弹 💣",
    "设置": "设置",
    "难度": "难度",
    "范围": "范围",
    "最佳": "最佳",
    "次": "次",
    "最佳: 暂无": "最佳: 暂无",
    "在这里输入数字": "在这里输入数字",
    "猜！": "猜！",
    "新游戏": "新游戏",
    "你用了 %d 次猜中！": "你用了 %d 次猜中！",
    "请输入一个有效的数字！": "请输入一个有效的数字！",
    "🎉 恭喜！你猜中了！": "🎉 恭喜！你猜中了！",
    "⬆️ 猜小了，再大一点": "⬆️ 猜小了，再大一点",
    "⬇️ 猜大了，再小一点": "⬇️ 猜大了，再小一点",
    "猜一个 1~%d 的数字": "猜一个 1~%d 的数字",
    "语言": "语言",
    "自定义难度范围": "自定义难度范围",
    "最小值": "最小值",
    "最大值": "最大值",
    "完成": "完成",
    "帮助": "帮助",
    "📖 帮助": "📖 帮助",
    "游戏规则：": "游戏规则：",
    "1. 系统随机生成一个1~范围内的数字作为“炸弹”。": "1. 系统随机生成一个1~范围内的数字作为“炸弹”。",
    "2. 你在输入框中输入猜测的数字，然后点击“猜！”。": "2. 你在输入框中输入猜测的数字，然后点击“猜！”。",
    "3. 系统会提示“猜大了”或“猜小了”，直到猜中为止。": "3. 系统会提示“猜大了”或“猜小了”，直到猜中为止。",
    "4. 猜中后游戏结束，并记录本次猜测次数。": "4. 猜中后游戏结束，并记录本次猜测次数。",
    "5. 每个难度有独立的最佳成绩记录。": "5. 每个难度有独立的最佳成绩记录。",
    "操作说明：": "操作说明：",
    "• 点击难度选择器可切换难度。": "• 点击难度选择器可切换难度。",
    "• 点击“新游戏”可重置当前难度的游戏。": "• 点击“新游戏”可重置当前难度的游戏。",
    "• 点击右上角齿轮图标打开设置，可调整自定义范围和语言。": "• 点击右上角齿轮图标打开设置，可调整自定义范围和语言。",
    "• 最佳成绩会自动保存。": "• 最佳成绩会自动保存。",
    "关闭": "关闭",
    "选择语言": "选择语言",
    "取消": "取消"
]

let englishText: [String: String] = [
    "💣 数字炸弹 💣": "💣 Number Bomb 💣",
    "设置": "Settings",
    "难度": "Difficulty",
    "范围": "Range",
    "最佳": "Best",
    "次": "times",
    "最佳: 暂无": "Best: None",
    "在这里输入数字": "Enter a number",
    "猜！": "Guess!",
    "新游戏": "New Game",
    "你用了 %d 次猜中！": "You got it in %d guesses!",
    "请输入一个有效的数字！": "Please enter a valid number!",
    "🎉 恭喜！你猜中了！": "🎉 Congratulations! You got it!",
    "⬆️ 猜小了，再大一点": "⬆️ Too small, try bigger",
    "⬇️ 猜大了，再小一点": "⬇️ Too big, try smaller",
    "猜一个 1~%d 的数字": "Guess a number between 1 and %d",
    "语言": "Language",
    "自定义难度范围": "Custom Range",
    "最小值": "Min",
    "最大值": "Max",
    "完成": "Done",
    "帮助": "Help",
    "📖 帮助": "📖 Help",
    "游戏规则：": "Game Rules:",
    "1. 系统随机生成一个1~范围内的数字作为“炸弹”。": "1. The system randomly generates a number within the range as the 'bomb'.",
    "2. 你在输入框中输入猜测的数字，然后点击“猜！”。": "2. Enter your guess in the input box and tap 'Guess!'.",
    "3. 系统会提示“猜大了”或“猜小了”，直到猜中为止。": "3. You'll get hints 'Too big' or 'Too small' until you hit the bomb.",
    "4. 猜中后游戏结束，并记录本次猜测次数。": "4. The game ends when you guess correctly, and the number of attempts is recorded.",
    "5. 每个难度有独立的最佳成绩记录。": "5. Each difficulty level has its own best score.",
    "操作说明：": "Instructions:",
    "• 点击难度选择器可切换难度。": "• Use the difficulty picker to switch levels.",
    "• 点击“新游戏”可重置当前难度的游戏。": "• Tap 'New Game' to reset the current difficulty.",
    "• 点击右上角齿轮图标打开设置，可调整自定义范围和语言。": "• Tap the gear icon to open settings and adjust custom range & language.",
    "• 最佳成绩会自动保存。": "• Best scores are saved automatically.",
    "关闭": "Close",
    "选择语言": "Choose Language",
    "取消": "Cancel"
]

// MARK: - 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
