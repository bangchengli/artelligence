

import SwiftUI

@main
struct cacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ChatViewModel())
        }
    }
}
