import SwiftUI

struct DrawerView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing
    private let drawerWidth: CGFloat = 280

    var body: some View {
        @Bindable var appState = appState
        ZStack(alignment: .leading) {
            // Dim overlay
            if appState.isDrawerOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { appState.isDrawerOpen = false } }
            }

            // Drawer panel
            HStack(spacing: 0) {
                drawerContent
                    .frame(width: drawerWidth)
                    .background(colors.bgSurface)
                    .offset(x: appState.isDrawerOpen ? 0 : -drawerWidth)
                    .animation(.easeInOut(duration: 0.25), value: appState.isDrawerOpen)
                Spacer()
            }
        }
        .ignoresSafeArea()
    }

    private var drawerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Brand
            Text("wod")
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundStyle(colors.textPrimary)
                .padding(.horizontal, spacing.l)
                .padding(.top, spacing.xl + 24)
                .padding(.bottom, spacing.l)

            Divider().background(colors.divider)
            Spacer().frame(height: spacing.m)

            DrawerItem(icon: "timer", label: "Timer", selected: appState.path.isEmpty) {
                withAnimation(.easeInOut(duration: 0.25)) { appState.isDrawerOpen = false }
                appState.goHome()
            }
            DrawerItem(icon: "bookmark.fill", label: "I miei WOD", selected: appState.path.last == .library) {
                withAnimation(.easeInOut(duration: 0.25)) { appState.isDrawerOpen = false }
                if appState.path.last != .library {
                    appState.path.removeAll()
                    appState.path.append(.library)
                }
            }
            DrawerItem(icon: "list.bullet.rectangle", label: "Diario del workout", selected: appState.path.last == .diary) {
                withAnimation(.easeInOut(duration: 0.25)) { appState.isDrawerOpen = false }
                if appState.path.last != .diary {
                    appState.path.removeAll()
                    appState.path.append(.diary)
                }
            }
            DrawerItem(icon: "gearshape", label: "Impostazioni e aiuto", selected: appState.path.last == .settings) {
                withAnimation(.easeInOut(duration: 0.25)) { appState.isDrawerOpen = false }
                if appState.path.last != .settings {
                    appState.path.removeAll()
                    appState.path.append(.settings)
                }
            }

            Spacer()
            Divider().background(colors.divider)
            Text("Powered by Nicola D'Ambrosio")
                .font(.caption)
                .foregroundStyle(colors.textDisabled)
                .padding(.horizontal, spacing.l)
                .padding(.vertical, spacing.m)
        }
    }
}

private struct DrawerItem: View {
    let icon: String
    let label: String
    let selected: Bool
    let action: () -> Void
    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    var body: some View {
        Button(action: action) {
            HStack(spacing: spacing.m) {
                Image(systemName: icon)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(selected ? colors.textPrimary : colors.textSecondary)
                Text(label)
                    .font(.system(size: 16, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? colors.textPrimary : colors.textSecondary)
                Spacer()
            }
            .padding(.horizontal, spacing.m)
            .padding(.vertical, spacing.m)
            .background(
                selected ? colors.bgElevated : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .padding(.horizontal, spacing.m)
        }
    }
}
