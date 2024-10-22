import UIKit
import ParseSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .dark
        
       
        let launchVC = LaunchScreenViewController()
        window?.rootViewController = launchVC
        window?.makeKeyAndVisible()
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkAuthAndUpdateRootVC()
        }
    }
    
    private func checkAuthAndUpdateRootVC() {
        if User.current != nil {
            
            let feedViewController = FeedViewController()
            let navigationController = UINavigationController(rootViewController: feedViewController)
            
            
            UIView.transition(with: window!,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                self.window?.rootViewController = navigationController
            })
        } else {
            
            let loginViewController = LoginViewController()
            
            
            UIView.transition(with: window!,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                self.window?.rootViewController = loginViewController
            })
        }
    }
}
