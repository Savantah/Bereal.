import UIKit
import ParseSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeParse()
        return true
    }

    private func initializeParse() {
        do {
            try ParseSwift.initialize(
                applicationId: "Xd25OOm8ugydh6jqFMagKGybRzcDX7On0FVHo2rJ",
                clientKey: "J9dncqJW6iO4iVJxlE2FjCSJ8xJMTNJLa5Tj61et",
                serverURL: URL(string: "https://parseapi.back4app.com")!
            )
            print("✅ Parse initialized successfully")
        } catch {
            print("❌ Error initializing Parse: \(error)")
        }
    }

   

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
