import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        ZStack(alignment: .leading) {
            NavigationStack(path: $appState.path) {
                HomeView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .config(let type):  ConfigRouterView(type: type)
                        case .timer:             TimerRunningView()
                        case .completion:        CompletionView()
                        case .library:           WodsLibraryView()
                        case .wodDetail(let id): WodDetailView(wodId: id)
                        case .diary:             DiaryView()
                        case .diaryDetail(let id): DiaryDetailView(logId: id)
                        case .settings:          SettingsView()
                        }
                    }
            }
            .onChange(of: appState.path) { _, path in
                let last = path.last
                let wantLandscape = last == .timer || last == .completion
                OrientationManager.lock(portrait: !wantLandscape)
            }
            .tint(.white)
            .disabled(appState.isDrawerOpen)

            DrawerView()
        }
    }
}

struct ConfigRouterView: View {
    let type: TimerType
    @Environment(AppState.self) private var appState

    var body: some View {
        switch type {
        case .amrap:   AmrapConfigView()
        case .forTime: ForTimeConfigView()
        case .emom:    EmomConfigView()
        case .tabata:  TabataConfigView()
        case .custom:  CustomConfigView()
        case .mix:     Text("MIX non ancora disponibile").foregroundStyle(.secondary)
        }
    }
}
