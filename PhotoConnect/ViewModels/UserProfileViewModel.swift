import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ImageItem: Identifiable {
    let id = UUID()
    let imageName: String
    let timestamp: Timestamp
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

        print("Fetching images for user with UID: \(uid)")

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

            guard let imageData = document.data()?["images"] as? [[String: Any]] else {
                print("No image data found in user document")
                return
            }

            var newImages: [ImageItem] = []

            for imageDataDict in imageData {
                if let imageName = imageDataDict["url"] as? String,
                   let timestamp = imageDataDict["timestamp"] as? Timestamp {
                    let newImage = ImageItem(imageName: imageName, timestamp: timestamp)
                    newImages.append(newImage)
                } else {
                    print("Error parsing image data")
                }
            }

            newImages.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })

            DispatchQueue.main.async {
                self.images = newImages
            }
        }
    }

    private func unsubscribe() {
        userListener?.remove()
    }
}
