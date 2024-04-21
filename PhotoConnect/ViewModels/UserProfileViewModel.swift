import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var userName: String = "Laddar..."

    init() {
        fetchUserName()
    }

    func fetchUserName() {
        guard let uid = Auth.auth().currentUser?.uid else {
            userName = "Ingen inloggad"
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                self.userName = document.data()?["name"] as? String ?? "Anonym användare"
            } else {
                self.userName = "Anonym användare"
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
