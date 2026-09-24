import SwiftUI

@main
struct ProofreaderApp: App {
    var body: some Scene {
        // Lives in the menu bar; .window style shows a popover-like panel
        MenuBarExtra("Proofreader", systemImage: "checkmark.bubble") {
            ContentView()
        }
        .menuBarExtraStyle(.window)

        // Standard Settings scene, opened with Cmd+,
        Settings {
            SettingsView()
        }
    }
}
