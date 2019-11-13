import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var adminVC: LobbyAdminViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LobbyAdmin")
        return controller as! LobbyAdminViewController
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        adminVC.sessionManager.application(app, open: url, options: options)
        return true
    }
    
    func startSession(){
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userModifyPlaybackState, .userReadPlaybackState]
        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            adminVC.sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            adminVC.sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: adminVC)
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if (adminVC.appRemote.isConnected) {
            adminVC.appRemote.disconnect()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let _ = adminVC.appRemote.connectionParameters.accessToken {
            adminVC.appRemote.connect()
        }
    }
}
