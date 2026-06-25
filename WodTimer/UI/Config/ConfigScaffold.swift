import SwiftUI

/// Shared scaffold for all config screens: title bar + scrollable body + bottom CTA.
struct ConfigScaffold<Content: View>: View {
    let title: String
    let accentColor: Color
    let totalSeconds: Int
    let ctaLabel: String
    let onStart: () -> Void
    var configForSave: TimerConfig? = nil
    @ViewBuilder let content: () -> Content

    @Environment(\.dismiss) private var dismiss
    @State private var showSaveSheet = false
    private let colors = WodTheme.colors

    var body: some View {
        ZStack(alignment: .bottom) {
            colors.bgPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                    Spacer().frame(height: 120) // space for bottom CTA
                }
                .padding(.horizontal, 16)
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider().background(colors.divider)
                HStack(spacing: 10) {
                    Button(action: onStart) {
                        HStack {
                            Text(ctaLabel)
                                .font(.system(size: 17, weight: .bold))
                            if totalSeconds > 0 {
                                Text("· \(formatSeconds(totalSeconds))")
                                    .font(.system(size: 15))
                                    .opacity(0.7)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(accentColor, in: RoundedRectangle(cornerRadius: 16))
                    }
                    if configForSave != nil {
                        Button { showSaveSheet = true } label: {
                            Image(systemName: "bookmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(colors.textPrimary)
                                .frame(width: 56, height: 56)
                                .background(colors.bgSurface, in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colors.bgPrimary)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showSaveSheet) {
            if let config = configForSave {
                SaveWodSheet(config: config, onDismiss: { showSaveSheet = false })
            }
        }
    }

    private func formatSeconds(_ s: Int) -> String {
        let m = s / 60; let sec = s % 60
        if m == 0 { return "\(sec)s" }
        if sec == 0 { return "\(m)m" }
        return "\(m)m \(sec)s"
    }
}
