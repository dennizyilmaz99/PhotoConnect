import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PhotoConnect: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()

        var body: some Scene {
            WindowGroup {
                if authViewModel.isUserAuthenticated {
                    HomeScreen() // Din huvudvy efter inloggning
                } else {
                    LoginScreen() // Din inloggningsvy
                }
            }
        }
}
