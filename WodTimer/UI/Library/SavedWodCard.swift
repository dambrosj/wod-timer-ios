import SwiftUI

struct SavedWodCard: View {
    let wod: SavedWod
    var onClick: (() -> Void)? = nil
    let onAvvia: () -> Void
    let onToggleFavourite: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    private let colors = WodTheme.colors
    private let spacing = WodTheme.spacing

    private var accent: Color { colors.accent(for: wod.type) }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 4, height: 52)

            Spacer().frame(width: spacing.m)

            // Text content
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: spacing.s) {
                    Text(wod.type.displayName)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                    if wod.isBuiltIn {
                        Text("BUILT-IN")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(colors.textDisabled)
                    }
                }
                Text(wod.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(colors.textPrimary)
                    .lineLimit(1)
                if !wod.description.isEmpty {
                    Text(wod.description)
                        .font(.system(size: 13))
                        .foregroundStyle(colors.textSecondary)
                        .lineLimit(2)
                }
                if wod.timesUsed > 0 {
                    Text("Usato \(wod.timesUsed)×")
                        .font(.system(size: 11))
                        .foregroundStyle(colors.textDisabled)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Favourite (heart icon, matching Android)
            Button(action: onToggleFavourite) {
                Image(systemName: wod.isFavourite ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundStyle(wod.isFavourite ? Color.red : colors.textDisabled)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            // AVVIA
            Button(action: onAvvia) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill").font(.caption)
                    Text("AVVIA")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(colors.bgPrimary)
                .padding(.horizontal, 10)
                .frame(height: 36)
                .background(accent, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            // Context menu
            Menu {
                Button { onDuplicate() } label: {
                    Label("Duplica", systemImage: "doc.on.doc")
                }
                if !wod.isBuiltIn {
                    Divider()
                    Button(role: .destructive) { onDelete() } label: {
                        Label("Elimina", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(colors.textSecondary)
                    .padding(.leading, 8)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
        .padding(spacing.m)
        .background(colors.bgSurface, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture { onClick?() }
    }
}
