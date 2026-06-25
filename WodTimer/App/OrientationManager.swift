import UIKit

enum OrientationManager {
    nonisolated(unsafe) static var allowLandscape: Bool = false

    @MainActor
    static func lock(portrait: Bool) {
        allowLandscape = !portrait
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let mask: UIInterfaceOrientationMask = portrait ? .portrait : .allButUpsideDown
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in }
    }
}
