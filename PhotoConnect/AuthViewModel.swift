import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated: Bool = false
    @Published var user: User?

    init() {
        self.user = Auth.auth().currentUser
        self.isUserAuthenticated = user != nil
    }

    func checkIfUserIsAuthenticated() {
        self.user = Auth.auth().currentUser
        self.isUserAuthenticated = user != nil
    }
}
