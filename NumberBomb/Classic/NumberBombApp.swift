import SwiftUI

@main
struct NumberBombApp: App {
    // 添加一个状态来控制帮助窗口的显示
    @State private var 显示帮助 = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 监听帮助菜单的点击
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("OpenHelp"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        显示帮助 = true
                    }
                }
                .sheet(isPresented: $显示帮助) {
                    帮助视图(当前语言: .simplifiedChinese) // 这里需要传入当前语言
                }
        }
        .commands {
            // 替换系统的帮助菜单
            CommandGroup(replacing: .help) {
                Button("NumberBomb Help") {
                    // 发送通知打开帮助
                    NotificationCenter.default.post(name: NSNotification.Name("OpenHelp"), object: nil)
                }
                .keyboardShortcut("?", modifiers: .command) // 添加快捷键 Cmd+?
            }
        }
    }
}
