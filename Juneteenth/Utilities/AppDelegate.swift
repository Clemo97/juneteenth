import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    /// Set this before navigating to control allowed orientations on a per-screen basis.
    /// Defaults to portrait-only (card selection screen).
    static var orientationMask: UIInterfaceOrientationMask = .portrait

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppDelegate.orientationMask
    }
}
