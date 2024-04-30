import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ImageItem: Identifiable {
    let id = UUID()  // Automatiskt genererat unikt ID
    let imageName: String
}


class UserProfileViewModel: ObservableObject {
    @Published var images: [ImageItem] = []
    @Published var userName: String = ""
    private var userListener: ListenerRegistration?

    init() {
        fetchImages()
        fetchUserName()
    }

    deinit {
        unsubscribe()
    }

    func fetchUserName() {
        guard let uid = Auth.auth().currentUser?.uid else {
            userName = "Ingen inloggad"
            return
        }

        let db = Firestore.firestore()
        userListener = db.collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                self.userName = "Anonym användare"
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }

            guard let document = documentSnapshot, document.exists else {
                self.userName = "Anonym användare"
                print("User document does not exist")
                return
            }

            if let data = document.data() {
                self.userName = data["name"] as? String ?? "Anonym användare"
            } else {
                self.userName = "Anonym användare"
                print("User document is empty")
            }
        }
    }

    func fetchImages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("User document does not exist")
                return
            }

            if let data = document.data(), let imageURLs = data["images"] as? [String] {
                DispatchQueue.main.async {
                    self.images = imageURLs.map { ImageItem(imageName: $0) }
                }
            } else {
                print("No image URLs found in user document")
            }
        }
    }

    private func unsubscribe() {
        userListener?.remove()
    }
}
