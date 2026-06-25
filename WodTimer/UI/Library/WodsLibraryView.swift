import SwiftUI

struct WodsLibraryView: View {
    @Environment(AppState.self) private var appState
    @State private var searchQuery = ""
    @State private var selectedType: TimerType? = nil
    @State private var wodToDelete: SavedWod? = nil

    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    private var filteredWods: [SavedWod] {
        appState.store.wods.filter { wod in
            let matchesType = selectedType == nil || wod.type == selectedType
            let matchesSearch = searchQuery.isEmpty
                || wod.name.localizedCaseInsensitiveContains(searchQuery)
                || wod.description.localizedCaseInsensitiveContains(searchQuery)
            return matchesType && matchesSearch
        }
    }

    var body: some View {
        ZStack {
            colors.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                searchBar
                    .padding(.horizontal, spacing.m)
                    .padding(.top, spacing.s)
                typeFilterRow
                    .padding(.vertical, spacing.s)
                Divider().background(colors.divider)
                content
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog(
            "Sei sicuro di voler eliminare «\(wodToDelete?.name ?? "")»?",
            isPresented: Binding(get: { wodToDelete != nil }, set: { if !$0 { wodToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Elimina", role: .destructive) {
                if let w = wodToDelete { appState.store.delete(w) }
                wodToDelete = nil
            }
            Button("Annulla", role: .cancel) { wodToDelete = nil }
        }
    }

    private var topBar: some View {
        HStack {
            Button { appState.path.removeLast() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colors.textPrimary)
            }
            Text("I miei WOD")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(colors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, spacing.m)
        .padding(.vertical, spacing.s)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(colors.textSecondary)
            TextField("Cerca WOD…", text: $searchQuery)
                .foregroundStyle(colors.textPrimary)
                .tint(colors.accentTabata)
            if !searchQuery.isEmpty {
                Button { searchQuery = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(colors.textSecondary)
                }
            }
        }
        .padding(.horizontal, spacing.m)
        .padding(.vertical, 10)
        .background(colors.bgSurface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var typeFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing.s) {
                filterChip(label: "Tutti", active: selectedType == nil) { selectedType = nil }
                ForEach(TimerType.allCases.filter { $0 != .mix }, id: \.self) { type in
                    filterChip(label: type.displayName, active: selectedType == type) {
                        selectedType = selectedType == type ? nil : type
                    }
                }
            }
            .padding(.horizontal, spacing.m)
        }
    }

    private func filterChip(label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? colors.accentTabata : colors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    active
                        ? colors.accentTabata.opacity(0.15)
                        : colors.bgSurface,
                    in: RoundedRectangle(cornerRadius: 20)
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        if filteredWods.isEmpty {
            VStack(spacing: spacing.m) {
                Spacer()
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 56))
                    .foregroundStyle(colors.textDisabled)
                Text("Nessun WOD trovato")
                    .font(.system(size: 17))
                    .foregroundStyle(colors.textSecondary)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: spacing.s) {
                    ForEach(filteredWods) { wod in
                        SavedWodCard(
                            wod: wod,
                            onClick: { appState.path.append(.wodDetail(wod.id)) },
                            onAvvia: { appState.startWod(wod) },
                            onToggleFavourite: { appState.store.toggleFavourite(wod) },
                            onDuplicate: { appState.store.duplicate(wod) },
                            onDelete: { if !wod.isBuiltIn { wodToDelete = wod } }
                        )
                    }
                }
                .padding(spacing.m)
            }
        }
    }
}
