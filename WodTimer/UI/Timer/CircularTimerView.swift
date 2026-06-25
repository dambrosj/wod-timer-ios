import SwiftUI

struct CircularTimerView: View {
    let phase: TimerPhase
    let ringColor: Color

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth = size * 0.07
            let progress = CGFloat(phase.progress)

            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time text
                Text(phase.formattedTime)
                    .font(.system(size: size * 0.22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
