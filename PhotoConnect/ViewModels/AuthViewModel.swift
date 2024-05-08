import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated: Bool = false
    @Published var user: User?
    
    private var listener: AuthStateDidChangeListenerHandle?
    
    init() {
        listener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.user = user
            self?.isUserAuthenticated = user != nil
        }
    }
    
    deinit {
        if let listener = listener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
