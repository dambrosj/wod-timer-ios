import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    @State private var exportURL: URL? = nil
    @State private var showImporter = false
    @State private var importResult: String? = nil

    var body: some View {
        @Bindable var settings = appState.settings
        ZStack {
            colors.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                Divider().background(colors.divider)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        audioSection(settings: settings)
                        Divider().background(colors.divider).padding(.vertical, spacing.l)
                        themeSection(settings: settings)
                        Divider().background(colors.divider).padding(.vertical, spacing.l)
                        dataSection
                        Spacer().frame(height: spacing.xl)
                    }
                    .padding(.horizontal, spacing.m)
                }
            }
        }
        .navigationBarHidden(true)
        .task { exportURL = appState.store.makeExportURL() }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                if let data = try? Data(contentsOf: url) {
                    let count = appState.store.importData(data)
                    importResult = count > 0
                        ? "Importati \(count) WOD con successo."
                        : "Nessun WOD valido trovato nel file."
                } else {
                    importResult = "Impossibile leggere il file."
                }
            case .failure:
                importResult = "Errore durante l'importazione."
            }
        }
        .alert(
            importResult ?? "",
            isPresented: Binding(get: { importResult != nil }, set: { if !$0 { importResult = nil } })
        ) {
            Button("OK") { importResult = nil }
        }
    }

    // MARK: – Top bar

    private var topBar: some View {
        HStack {
            Button { appState.path.removeLast() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colors.textPrimary)
            }
            Text("Impostazioni")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(colors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, spacing.m)
        .padding(.vertical, spacing.s)
    }

    // MARK: – Audio section

    @ViewBuilder
    private func audioSection(settings: SettingsStore) -> some View {
        sectionHeader("Audio")

        settingsRow(
            label: "Audio attivo",
            subtitle: "Attiva/disattiva tutti i suoni"
        ) {
            Toggle("", isOn: Binding(get: { settings.masterEnabled },
                                     set: { settings.masterEnabled = $0 }))
                .labelsHidden()
                .tint(colors.accentTabata)
        }

        if settings.masterEnabled {
            Spacer().frame(height: spacing.s)

            // Volume slider
            VStack(spacing: 4) {
                HStack {
                    Text("Volume segnali")
                        .font(.system(size: 16))
                        .foregroundStyle(colors.textPrimary)
                    Spacer()
                    Text("\(Int(settings.masterVolume * 100))%")
                        .font(.system(size: 14))
                        .foregroundStyle(colors.textSecondary)
                }
                Slider(value: Binding(get: { settings.masterVolume },
                                      set: { settings.masterVolume = $0 }),
                       in: 0...1)
                    .tint(colors.accentTabata)
            }
            .padding(.vertical, 6)

            settingsRow(
                label: "Conto alla rovescia",
                subtitle: "Bip negli ultimi 3 secondi"
            ) {
                Toggle("", isOn: Binding(get: { settings.countdownEnabled },
                                         set: { settings.countdownEnabled = $0 }))
                    .labelsHidden()
                    .tint(colors.accentTabata)
            }

            settingsRow(
                label: "A metà fase",
                subtitle: "Segnale a metà del tempo di lavoro"
            ) {
                Toggle("", isOn: Binding(get: { settings.halfwayEnabled },
                                         set: { settings.halfwayEnabled = $0 }))
                    .labelsHidden()
                    .tint(colors.accentTabata)
            }

            settingsRow(
                label: "Cambio fase",
                subtitle: "Segnale a ogni cambio di fase"
            ) {
                Toggle("", isOn: Binding(get: { settings.phaseTransitionEnabled },
                                         set: { settings.phaseTransitionEnabled = $0 }))
                    .labelsHidden()
                    .tint(colors.accentTabata)
            }

            settingsRow(
                label: "Completamento",
                subtitle: "Segnale a fine allenamento"
            ) {
                Toggle("", isOn: Binding(get: { settings.completionEnabled },
                                         set: { settings.completionEnabled = $0 }))
                    .labelsHidden()
                    .tint(colors.accentTabata)
            }
        }
    }

    // MARK: – Theme section

    @ViewBuilder
    private func themeSection(settings: SettingsStore) -> some View {
        sectionHeader("Tema")
        ForEach(ThemeMode.allCases, id: \.self) { mode in
            themeOption(label: mode.label,
                        selected: settings.themeMode == mode) {
                settings.themeMode = mode
            }
        }
    }

    // MARK: – Data section

    @ViewBuilder
    private var dataSection: some View {
        sectionHeader("Dati")

        if let url = exportURL {
            ShareLink(item: url) {
                dataRowContent(
                    label: "Esporta WOD",
                    subtitle: "Salva tutti i WOD in un file JSON",
                    systemImage: "square.and.arrow.up"
                )
            }
            .buttonStyle(.plain)
        }

        Spacer().frame(height: spacing.s)

        dataRow(
            label: "Importa WOD",
            subtitle: "Carica WOD da un file JSON (sovrascrive se esistenti)",
            systemImage: "square.and.arrow.down"
        ) {
            showImporter = true
        }
    }

    // MARK: – Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(colors.textDisabled)
            .padding(.vertical, spacing.s)
    }

    private func settingsRow<Control: View>(
        label: String,
        subtitle: String,
        @ViewBuilder control: () -> Control
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(colors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(colors.textSecondary)
            }
            Spacer()
            control()
        }
        .padding(.vertical, 6)
    }

    private func dataRowContent(label: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: spacing.m) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundStyle(colors.accentTabata)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(colors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(colors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colors.textDisabled)
        }
        .padding(.vertical, 8)
    }

    private func dataRow(label: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            dataRowContent(label: label, subtitle: subtitle, systemImage: systemImage)
        }
    }

    private func themeOption(label: String, selected: Bool, onSelect: @escaping () -> Void) -> some View {
        Button(action: onSelect) {
            HStack(spacing: spacing.s) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? colors.accentTabata : colors.textDisabled)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(colors.textPrimary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}
