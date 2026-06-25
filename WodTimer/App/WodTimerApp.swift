import SwiftUI

@main
struct WodTimerApp: App {
    @UIApplicationDelegateAdaptor(WodAppDelegate.self) var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(colorScheme(for: appState.settings.themeMode))
        }
    }

    private func colorScheme(for mode: ThemeMode) -> ColorScheme? {
        switch mode {
        case .dark:  return .dark
        case .light: return .light
        case .auto:  return nil
        }
    }
}
